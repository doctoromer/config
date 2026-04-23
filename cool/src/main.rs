use std::path::PathBuf;

use argh::FromArgs;
use tracing::Level;
use tracing_subscriber::EnvFilter;

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

fn download(_root_dir: &PathBuf) {
    todo!("Download command not yet implemented");
}

fn main() {
    let cli: Cli = argh::from_env();
    configure_logger(cli.verbose);
    let root_dir = root_dir();

    match cli.command {
        Commands::Download(_) => download(&root_dir),
    }
}
