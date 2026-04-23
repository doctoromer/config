use std::path::PathBuf;
use std::process::Command;

use argh::FromArgs;
use tracing::Level;
use tracing_subscriber::EnvFilter;

const BINARIES_DIR: &str = "binaries";
const ZSH_DIR: &str = "zsh";

#[derive(FromArgs)]
#[argh(subcommand)]
enum Commands {
    Download(DownloadArgs),
}

#[derive(FromArgs)]
#[argh(subcommand, name = "download", description = "download dependencies")]
struct DownloadArgs {}

#[derive(FromArgs)]
#[argh(description = "cool config manager")]
struct Cli {
    #[argh(switch, short = 'v', description = "verbose output")]
    verbose: bool,

    #[argh(subcommand)]
    command: Commands,
}

fn root_dir() -> PathBuf {
    std::env::current_dir().expect("Failed to determine current directory")
}

fn configure_logger(verbose: bool) {
    let level = if verbose { Level::DEBUG } else { Level::INFO };
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env().add_directive(level.into()))
        .init();
}

fn check_prerequisites() -> Result<(), Vec<&'static str>> {
    let required = ["git", "zsh"];
    let missing: Vec<_> = required
        .into_iter()
        .filter(|cmd| which::which(cmd).is_err())
        .collect();
    if missing.is_empty() {
        Ok(())
    } else {
        Err(missing)
    }
}

fn download_submodules() {
    tracing::info!("Downloading submodules");
    let status = Command::new("git")
        .args(["submodule", "update", "--init"])
        .status()
        .expect("Failed to run git");
    if !status.success() {
        tracing::error!("git submodule update --init failed");
    }
}

fn download_binaries() {
    tracing::info!("Downloading binaries");
    todo!();
}

fn download_vim_plugins(root_dir: &PathBuf) {
    tracing::info!("Downloading vim plugins");
    let nvim_path = root_dir.join(BINARIES_DIR).join("usr/bin/nvim");
    let status = Command::new(nvim_path)
        .args(["--appimage-extract-and-run", "--headless"])
        .env("DOWNLOAD_MODE", "true")
        .env("XDG_CONFIG_HOME", root_dir)
        .status()
        .expect("Failed to run nvim");
    if !status.success() {
        tracing::error!("nvim --headless failed");
    }
}

fn update_zsh_plugins(root_dir: &PathBuf) {
    tracing::info!("Updating zsh plugins");
    let plugins_path = root_dir.join(ZSH_DIR).join("plugins.zsh");
    let status = Command::new("zsh")
        .arg("-c")
        .arg(format!("source {}", plugins_path.display()))
        .arg("-c")
        .arg("zcomet update")
        .status()
        .expect("Failed to run zsh");
    if !status.success() {
        tracing::error!("zcomet update failed");
    }
}

fn fix_permissions(root_dir: &PathBuf) {
    if let Some(real_user) = std::env::var_os("SUDO_USER") {
        let nvim_share = PathBuf::from(format!("/home/{}/.local/share/nvim", real_user.to_string_lossy()));
        let status = Command::new("chown")
            .args(["-f", "-R"])
            .arg(&real_user)
            .arg(root_dir)
            .arg(nvim_share)
            .status()
            .expect("Failed to run chown");
        if !status.success() {
            tracing::error!("chown failed");
        }
    }
}

fn download(root_dir: &PathBuf) {
    if let Err(missing) = check_prerequisites() {
        tracing::error!(
            "Please install the following commands: {}",
            missing.join(", ")
        );
        return;
    }

    download_submodules();
    download_binaries();
    download_vim_plugins(root_dir);
    update_zsh_plugins(root_dir);
    fix_permissions(root_dir);
}

fn main() {
    let cli: Cli = argh::from_env();
    configure_logger(cli.verbose);
    let root_dir = root_dir();

    match cli.command {
        Commands::Download(_) => download(&root_dir),
    }
}
