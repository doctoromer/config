use std::collections::BTreeMap;
use std::fs::{self, File};
use std::io::Cursor;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{Context, Result, bail};
use flate2::read::GzDecoder;
use regex::Regex;
use reqwest::blocking::{Client, RequestBuilder};
use serde::Deserialize;
use tar::Archive;
use zip::ZipArchive;

use crate::run;

const BINARIES_DIR: &str = "binaries";
const SOURCE_CODE_ASSET: &str = "SOURCE_CODE_ASSET.zip";
const SYM_RELEASES_URL: &str = "https://gitlab.com/api/v4/projects/OmerSarig%2Fsym/releases";

#[derive(Deserialize)]
struct Binary {
    repo: String,
    asset_regex: String,
    file_map: BTreeMap<String, String>,
    tag: Option<String>,
}

#[derive(Deserialize)]
struct GithubAsset {
    name: String,
    browser_download_url: String,
}

#[derive(Deserialize)]
struct GithubRelease {
    zipball_url: String,
    assets: Vec<GithubAsset>,
}

#[derive(Deserialize)]
struct GitlabLink {
    name: String,
    url: String,
}

#[derive(Deserialize)]
struct GitlabAssets {
    links: Vec<GitlabLink>,
}

#[derive(Deserialize)]
struct GitlabRelease {
    tag_name: String,
    assets: GitlabAssets,
}

fn request(client: &Client, url: &str) -> RequestBuilder {
    let request = client.get(url);
    match std::env::var("GITHUB_TOKEN") {
        Ok(token) if url.starts_with("https://api.github.com/") => request.bearer_auth(token),
        _ => request,
    }
}

fn get_json<T: for<'de> Deserialize<'de>>(client: &Client, url: &str) -> Result<T> {
    request(client, url)
        .send()
        .with_context(|| format!("Failed to download {url}"))?
        .error_for_status()
        .with_context(|| format!("Failed to download {url}"))?
        .json()
        .with_context(|| format!("Failed to parse {url}"))
}

fn get_bytes(client: &Client, url: &str) -> Result<Vec<u8>> {
    Ok(request(client, url)
        .send()
        .with_context(|| format!("Failed to download {url}"))?
        .error_for_status()
        .with_context(|| format!("Failed to download {url}"))?
        .bytes()?
        .to_vec())
}

fn github_release(client: &Client, binary: &Binary) -> Result<GithubRelease> {
    let release = match &binary.tag {
        Some(tag) => format!(
            "https://api.github.com/repos/{}/releases/tags/{tag}",
            binary.repo
        ),
        None => format!(
            "https://api.github.com/repos/{}/releases/latest",
            binary.repo
        ),
    };
    get_json(client, &release)
}

fn download_release_asset(client: &Client, binary: &Binary) -> Result<(String, Vec<u8>)> {
    let release = github_release(client, binary)?;
    if binary.asset_regex == SOURCE_CODE_ASSET {
        return Ok((
            SOURCE_CODE_ASSET.to_owned(),
            get_bytes(client, &release.zipball_url)?,
        ));
    }

    let asset_regex = Regex::new(&format!("^(?:{})$", binary.asset_regex))?;
    let asset = release
        .assets
        .into_iter()
        .find(|asset| asset_regex.is_match(&asset.name))
        .with_context(|| {
            format!(
                "No asset matching {} in the latest {} release",
                binary.asset_regex, binary.repo
            )
        })?;
    let data = get_bytes(client, &asset.browser_download_url)?;
    Ok((asset.name, data))
}

fn matching_output<'a>(
    entry_name: &str,
    file_map: &'a BTreeMap<String, String>,
) -> Result<Option<&'a str>> {
    let mut output = None;
    for (pattern, candidate) in file_map {
        let regex = Regex::new(&format!("^(?:{pattern})$"))?;
        if !regex.is_match(entry_name) {
            continue;
        }
        if output.is_some() {
            bail!("Multiple file-map entries match {entry_name}")
        }
        output = Some(candidate.as_str());
    }
    Ok(output)
}

fn prepare_output(path: &Path) -> Result<File> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    let file = File::create(path)?;
    fs::set_permissions(path, fs::Permissions::from_mode(0o755))?;
    Ok(file)
}

fn extract_tarball(
    data: &[u8],
    base_path: &Path,
    file_map: &BTreeMap<String, String>,
) -> Result<()> {
    let mut archive = Archive::new(GzDecoder::new(Cursor::new(data)));
    for entry in archive.entries()? {
        let mut entry = entry?;
        if !entry.header().entry_type().is_file() {
            continue;
        }
        let entry_name = entry.path()?.to_string_lossy().into_owned();
        let Some(output) = matching_output(&entry_name, file_map)? else {
            continue;
        };
        let output = base_path.join(output);
        if output.exists() {
            continue;
        }
        let mut file = prepare_output(&output)?;
        std::io::copy(&mut entry, &mut file)?;
    }
    Ok(())
}

fn extract_zip(
    name: &str,
    data: &[u8],
    base_path: &Path,
    file_map: &BTreeMap<String, String>,
) -> Result<()> {
    let mut archive = ZipArchive::new(Cursor::new(data))?;
    for index in 0..archive.len() {
        let mut entry = archive.by_index(index)?;
        if !entry.is_file() {
            continue;
        }
        let entry_name = if name == SOURCE_CODE_ASSET {
            Path::new(entry.name())
                .components()
                .skip(1)
                .collect::<PathBuf>()
                .to_string_lossy()
                .into_owned()
        } else {
            entry.name().to_owned()
        };
        let Some(output) = matching_output(&entry_name, file_map)? else {
            continue;
        };
        let output = base_path.join(output);
        if output.exists() {
            continue;
        }
        let mut file = prepare_output(&output)?;
        std::io::copy(&mut entry, &mut file)?;
    }
    Ok(())
}

fn write_or_extract(
    name: &str,
    data: &[u8],
    base_path: &Path,
    file_map: &BTreeMap<String, String>,
) -> Result<()> {
    if name.ends_with(".tar.gz") {
        extract_tarball(data, base_path, file_map)
    } else if name.ends_with(".zip") {
        extract_zip(name, data, base_path, file_map)
    } else {
        let output = file_map
            .get(name)
            .with_context(|| format!("No output configured for {name}"))?;
        let output = base_path.join(output);
        if output.exists() {
            return Ok(());
        }
        let mut file = prepare_output(&output)?;
        std::io::copy(&mut Cursor::new(data), &mut file)?;
        Ok(())
    }
}

fn download_required(binary: &Binary, base_path: &Path) -> bool {
    binary
        .file_map
        .values()
        .any(|output| !base_path.join(output).exists())
}

fn download_sym(client: &Client, base_path: &Path) -> Result<()> {
    let output = base_path.join("usr/bin/sym");
    if output.exists() {
        return Ok(());
    }

    let tag_regex = Regex::new(r"^sym-v(\d+(?:\.\d+)*)$")?;
    let releases: Vec<GitlabRelease> = get_json(client, SYM_RELEASES_URL)?;
    let mut releases: Vec<_> = releases
        .into_iter()
        .filter_map(|release| {
            let captures = tag_regex.captures(&release.tag_name)?;
            let version = captures[1]
                .split('.')
                .map(str::parse::<u64>)
                .collect::<Result<Vec<_>, _>>()
                .ok()?;
            Some((version, release))
        })
        .collect();
    releases.sort_by(|left, right| left.0.cmp(&right.0));
    let release = releases.pop().context("No sym release found")?.1;
    let link = release
        .assets
        .links
        .into_iter()
        .find(|link| link.name == "sym")
        .context("No sym release asset found")?;
    let data = get_bytes(client, &link.url)?;
    let mut file = prepare_output(&output)?;
    std::io::copy(&mut Cursor::new(data), &mut file)?;
    Ok(())
}

fn download_binaries(client: &Client, root_dir: &Path) -> Result<()> {
    tracing::info!("Downloading binaries");
    let config: BTreeMap<String, Binary> =
        serde_json::from_reader(File::open(root_dir.join("binaries.json"))?)?;
    let base_path = root_dir.join(BINARIES_DIR);
    download_sym(client, &base_path)?;
    for (name, binary) in config {
        if !download_required(&binary, &base_path) {
            tracing::debug!("Downloading {name} is not required");
            continue;
        }
        tracing::info!("Downloading {name}");
        let (asset_name, data) = download_release_asset(client, &binary)?;
        write_or_extract(&asset_name, &data, &base_path, &binary.file_map)?;
    }
    Ok(())
}

fn check_prerequisites() -> Result<()> {
    let missing: Vec<_> = ["git", "zsh"]
        .into_iter()
        .filter(|command| which::which(command).is_err())
        .collect();
    if missing.is_empty() {
        Ok(())
    } else {
        bail!(
            "Please install the following commands: {}",
            missing.join(", ")
        )
    }
}

fn download_submodules(root_dir: &Path) -> Result<()> {
    tracing::info!("Downloading submodules");
    run(Command::new("git")
        .current_dir(root_dir)
        .args(["submodule", "update", "--init"]))
}

fn download_vim_plugins(root_dir: &Path) -> Result<()> {
    tracing::info!("Downloading vim plugins");
    run(
        Command::new(root_dir.join(BINARIES_DIR).join("usr/bin/nvim"))
            .current_dir(root_dir)
            .args(["--appimage-extract-and-run", "--headless"])
            .env("DOWNLOAD_MODE", "true")
            .env("XDG_CONFIG_HOME", root_dir),
    )
}

fn update_zsh_plugins(root_dir: &Path) -> Result<()> {
    tracing::info!("Updating zsh plugins");
    let plugins_path = root_dir.join("zsh/plugins.zsh");
    run(Command::new("zsh")
        .current_dir(root_dir)
        .args(["-c", "source \"$1\"; zcomet update", "cool"])
        .arg(plugins_path))
}

fn fix_permissions(root_dir: &Path) -> Result<()> {
    let Some(real_user) = std::env::var_os("SUDO_USER") else {
        return Ok(());
    };
    let nvim_share = PathBuf::from("/home")
        .join(&real_user)
        .join(".local/share/nvim");
    run(Command::new("chown")
        .args(["-f", "-R"])
        .arg(&real_user)
        .arg(root_dir)
        .arg(nvim_share))
}

pub fn download(root_dir: &Path) -> Result<()> {
    check_prerequisites()?;
    let client = Client::builder().user_agent("cool-config").build()?;
    download_submodules(root_dir)?;
    download_binaries(&client, root_dir)?;
    download_vim_plugins(root_dir)?;
    update_zsh_plugins(root_dir)?;
    fix_permissions(root_dir)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn matches_exactly_one_output() {
        let map = BTreeMap::from([
            ("bin/tool".to_owned(), "usr/bin/tool".to_owned()),
            ("doc/.*".to_owned(), "usr/share/man/tool.1".to_owned()),
        ]);
        assert_eq!(
            matching_output("bin/tool", &map).unwrap(),
            Some("usr/bin/tool")
        );
        assert_eq!(matching_output("other", &map).unwrap(), None);
    }

    #[test]
    fn parses_binary_configuration() {
        let binaries: BTreeMap<String, Binary> =
            serde_json::from_str(include_str!("../../binaries.json")).unwrap();
        assert!(binaries.contains_key("nvim") || binaries.contains_key("vim"));
        assert!(binaries.values().all(|binary| !binary.file_map.is_empty()));
    }
}
