use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{Context, Result, bail};

use argh::FromArgs;
use tracing::Level;
use tracing_subscriber::EnvFilter;

mod download;

const BINARIES_DIR: &str = "binaries";
const PACKAGES: [&str; 4] = ["misc", "nvim", "zsh", "binaries"];

#[derive(FromArgs)]
#[argh(subcommand)]
enum Commands {
    Download(DownloadArgs),
    Install(InstallArgs),
    Remove(RemoveArgs),
}

#[derive(FromArgs)]
#[argh(subcommand, name = "download", description = "download dependencies")]
struct DownloadArgs {}

#[derive(FromArgs)]
#[argh(
    subcommand,
    name = "install",
    description = "install the configuration"
)]
struct InstallArgs {
    #[argh(option, short = 'p', description = "comma-separated packages")]
    packages: Option<String>,

    #[argh(
        option,
        default = "String::from(\"system\")",
        description = "linkmap profile"
    )]
    profile: String,
}

#[derive(FromArgs)]
#[argh(subcommand, name = "remove", description = "remove the configuration")]
struct RemoveArgs {
    #[argh(option, short = 'p', description = "comma-separated packages")]
    packages: Option<String>,

    #[argh(
        option,
        default = "String::from(\"system\")",
        description = "linkmap profile"
    )]
    profile: String,
}

#[derive(FromArgs)]
#[argh(description = "cool config manager")]
struct Cli {
    #[argh(switch, short = 'v', description = "verbose output")]
    verbose: bool,

    #[argh(option, description = "config root directory")]
    root: Option<PathBuf>,

    #[argh(subcommand)]
    command: Commands,
}

fn is_root(path: &Path) -> bool {
    path.join("binaries.json").is_file() && path.join("linkmap.toml").is_file()
}

fn find_root(path: &Path) -> Option<PathBuf> {
    path.ancestors()
        .find(|path| is_root(path))
        .map(Path::to_owned)
}

fn root_dir(explicit_root: Option<PathBuf>) -> Result<PathBuf> {
    if let Some(root) = explicit_root {
        if is_root(&root) {
            return Ok(root);
        }
        bail!("{} is not a config root", root.display());
    }

    let current_dir = std::env::current_dir().context("Failed to determine current directory")?;
    if let Some(root) = find_root(&current_dir) {
        return Ok(root);
    }

    let executable = std::env::current_exe().context("Failed to determine executable path")?;
    if let Some(root) = executable.parent().and_then(find_root) {
        return Ok(root);
    }

    bail!("Could not find the config root; pass it with --root")
}

fn configure_logger(verbose: bool) {
    let level = if verbose { Level::DEBUG } else { Level::INFO };
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env().add_directive(level.into()))
        .init();
}

fn package_regex(packages: Option<&str>) -> Result<Option<String>> {
    let Some(packages) = packages else {
        return Ok(None);
    };
    let packages: Vec<_> = packages.split(',').collect();
    if packages.is_empty() || packages.iter().any(|package| !PACKAGES.contains(package)) {
        bail!("Invalid packages: {}", packages.join(","));
    }
    Ok(Some(packages.join("|")))
}

fn validate_profile(profile: &str) -> Result<()> {
    if matches!(profile, "local" | "system") {
        Ok(())
    } else {
        bail!("Invalid profile: {profile}")
    }
}

fn run(command: &mut Command) -> Result<()> {
    let description = format!("{command:?}");
    let status = command
        .status()
        .with_context(|| format!("Failed to execute {description}"))?;
    if status.success() {
        Ok(())
    } else {
        bail!("{description} exited with {status}")
    }
}

fn configure_links(
    root_dir: &Path,
    action: &str,
    packages: Option<&str>,
    profile: &str,
) -> Result<()> {
    validate_profile(profile)?;
    let mut command = Command::new(root_dir.join(BINARIES_DIR).join("usr/bin/sym"));
    command
        .current_dir(root_dir)
        .arg(action)
        .arg("--linkmap")
        .arg(root_dir.join("linkmap.toml"))
        .arg("--profile")
        .arg(profile)
        .env("RUST_BACKTRACE", "1");
    if let Some(regex) = package_regex(packages)? {
        command.arg("--regex").arg(regex);
    }
    run(&mut command)
}

fn installed_syms(profile: &str) -> Result<Vec<PathBuf>> {
    match profile {
        "system" => Ok(vec![
            PathBuf::from("/usr/bin/sym"),
            PathBuf::from("/usr/local/bin/sym"),
        ]),
        "local" => Ok(vec![
            PathBuf::from(std::env::var_os("HOME").context("HOME is not set")?)
                .join(".local/bin/sym"),
        ]),
        _ => bail!("Invalid profile: {profile}"),
    }
}

fn remove_previous_installation(
    root_dir: &Path,
    packages: Option<&str>,
    profile: &str,
) -> Result<()> {
    let current_root = root_dir.canonicalize()?;
    for installed_sym in installed_syms(profile)? {
        let Ok(metadata) = std::fs::symlink_metadata(&installed_sym) else {
            continue;
        };
        if !metadata.file_type().is_symlink() {
            continue;
        }

        let previous_sym = installed_sym
            .canonicalize()
            .with_context(|| format!("Failed to resolve {}", installed_sym.display()))?;
        let Some(previous_root) = find_root(&previous_sym) else {
            continue;
        };
        if previous_root == current_root {
            return Ok(());
        }

        tracing::info!(
            "Removing previous installation from {}",
            previous_root.display()
        );
        return configure_links(&previous_root, "unlink", packages, profile);
    }
    Ok(())
}

fn install(root_dir: &Path, args: InstallArgs) -> Result<()> {
    remove_previous_installation(root_dir, args.packages.as_deref(), &args.profile)?;
    configure_links(root_dir, "link", args.packages.as_deref(), &args.profile)?;
    if args.profile == "local" {
        run(Command::new("git").args([
            "config",
            "--global",
            "include.path",
            "~/.config/gitconfig",
        ]))?;
    }
    Ok(())
}

fn remove(root_dir: &Path, args: RemoveArgs) -> Result<()> {
    configure_links(root_dir, "unlink", args.packages.as_deref(), &args.profile)?;
    if args.profile == "local" {
        let _ = Command::new("git")
            .args(["config", "--global", "--unset", "include.path"])
            .status();
    }
    Ok(())
}

fn main() -> Result<()> {
    let cli: Cli = argh::from_env();
    configure_logger(cli.verbose);
    let root_dir = root_dir(cli.root)?;
    tracing::info!("Running from: {}", root_dir.display());

    match cli.command {
        Commands::Download(_) => download::download(&root_dir),
        Commands::Install(args) => install(&root_dir, args),
        Commands::Remove(args) => remove(&root_dir, args),
    }
}

#[cfg(test)]
mod tests {
    use std::fs;

    use super::*;

    #[test]
    fn finds_root_from_descendant() {
        let root = std::env::temp_dir().join(format!("cool-root-{}", std::process::id()));
        let descendant = root.join("a/b");
        fs::create_dir_all(&descendant).unwrap();
        fs::write(root.join("binaries.json"), "{}").unwrap();
        fs::write(root.join("linkmap.toml"), "").unwrap();

        assert_eq!(find_root(&descendant), Some(root.clone()));

        fs::remove_dir_all(root).unwrap();
    }

    #[test]
    fn builds_package_regex() {
        assert_eq!(
            package_regex(Some("nvim,misc")).unwrap(),
            Some("nvim|misc".to_owned())
        );
        assert!(package_regex(Some("unknown")).is_err());
    }
}
