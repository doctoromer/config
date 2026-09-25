use std::fs;
use std::os::unix::fs::{PermissionsExt, symlink};
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::atomic::{AtomicU64, Ordering};

static NEXT_TEMP_DIR: AtomicU64 = AtomicU64::new(0);
const SYM_SCRIPT: &str = "#!/bin/sh\n[ \"$2\" = --linkmap ] && [ \"$4\" = --profile ] && [ \"$5\" = local ] || exit 2\ncase $1 in\nlink) ln -s \"$SYM_SOURCE\" \"$SYM_TARGET\";;\nunlink) rm \"$SYM_TARGET\";;\n*) exit 2;;\nesac\n";

struct TempDir(PathBuf);

impl TempDir {
    fn new() -> Self {
        let id = NEXT_TEMP_DIR.fetch_add(1, Ordering::Relaxed);
        let path = std::env::temp_dir().join(format!("cool-test-{}-{id}", std::process::id()));
        fs::create_dir_all(&path).unwrap();
        Self(path)
    }

    fn path(&self) -> &Path {
        &self.0
    }
}

impl Drop for TempDir {
    fn drop(&mut self) {
        fs::remove_dir_all(&self.0).unwrap();
    }
}

fn copy_executable(source: impl AsRef<Path>, target: impl AsRef<Path>) {
    let target = target.as_ref();
    fs::create_dir_all(target.parent().unwrap()).unwrap();
    fs::copy(source, target).unwrap();
    fs::set_permissions(target, fs::Permissions::from_mode(0o755)).unwrap();
}

fn write_executable(path: impl AsRef<Path>, contents: &str) {
    let path = path.as_ref();
    fs::create_dir_all(path.parent().unwrap()).unwrap();
    fs::write(path, contents).unwrap();
    fs::set_permissions(path, fs::Permissions::from_mode(0o755)).unwrap();
}

fn test_path(bin: &Path) -> std::ffi::OsString {
    let mut paths = vec![bin.to_owned()];
    paths.extend(std::env::split_paths(
        &std::env::var_os("PATH").unwrap_or_default(),
    ));
    std::env::join_paths(paths).unwrap()
}

fn cool_command(
    cool: &Path,
    work_dir: &Path,
    home: &Path,
    source: &Path,
    target: &Path,
) -> Command {
    let mut command = Command::new(cool);
    command
        .current_dir(work_dir)
        .env("HOME", home)
        .env("GIT_CONFIG_GLOBAL", home.join(".gitconfig"))
        .env("SYM_SOURCE", source)
        .env("SYM_TARGET", target);
    command
}

#[test]
fn installs_and_removes_from_extracted_bundle() {
    let temp = TempDir::new();
    let bundle = temp.path().join("bundle");
    let previous_bundle = temp.path().join("previous");
    let home = temp.path().join("home");
    let source = bundle.join("package");
    let previous_source = previous_bundle.join("package");
    let target = home.join("installed");
    let work_dir = temp.path().join("work");
    fs::create_dir_all(&source).unwrap();
    fs::create_dir_all(&previous_source).unwrap();
    fs::create_dir_all(home.join(".local/bin")).unwrap();
    fs::create_dir_all(&work_dir).unwrap();
    fs::write(bundle.join("binaries.json"), "{}").unwrap();
    fs::write(bundle.join("linkmap.toml"), "[local]\n").unwrap();
    fs::write(previous_bundle.join("binaries.json"), "{}").unwrap();
    fs::write(previous_bundle.join("linkmap.toml"), "[local]\n").unwrap();
    fs::write(source.join("config"), "content").unwrap();
    fs::write(previous_source.join("config"), "old content").unwrap();

    let cool = bundle.join("bin/cool");
    let previous_sym = previous_bundle.join("binaries/usr/bin/sym");
    copy_executable(env!("CARGO_BIN_EXE_cool"), &cool);
    write_executable(bundle.join("binaries/usr/bin/sym"), SYM_SCRIPT);
    write_executable(&previous_sym, SYM_SCRIPT);
    symlink(previous_sym, home.join(".local/bin/sym")).unwrap();
    symlink(&previous_source, &target).unwrap();

    let status = cool_command(&cool, &work_dir, &home, &source, &target)
        .args(["install", "--profile", "local"])
        .status()
        .unwrap();
    assert!(status.success());
    assert_eq!(fs::read_link(&target).unwrap(), source);
    assert_eq!(
        fs::read_to_string(target.join("config")).unwrap(),
        "content"
    );
    let include = Command::new("git")
        .args(["config", "--file"])
        .arg(home.join(".gitconfig"))
        .args(["--get", "include.path"])
        .output()
        .unwrap();
    assert_eq!(
        String::from_utf8(include.stdout).unwrap().trim(),
        "~/.config/gitconfig"
    );

    let status = cool_command(&cool, &work_dir, &home, &source, &target)
        .args(["remove", "--profile", "local"])
        .status()
        .unwrap();
    assert!(status.success());
    assert!(!target.exists());
    let include = Command::new("git")
        .args(["config", "--file"])
        .arg(home.join(".gitconfig"))
        .args(["--get", "include.path"])
        .status()
        .unwrap();
    assert!(!include.success());
}

#[test]
fn downloads_from_a_complete_offline_bundle() {
    let temp = TempDir::new();
    let bundle = temp.path().join("bundle");
    let work_dir = temp.path().join("work");
    let command_log = temp.path().join("commands.log");
    let fake_bin = temp.path().join("bin");
    fs::create_dir_all(&bundle).unwrap();
    fs::create_dir_all(&work_dir).unwrap();
    fs::write(bundle.join("binaries.json"), "{}").unwrap();
    fs::write(bundle.join("linkmap.toml"), "").unwrap();

    let cool = bundle.join("bin/cool");
    copy_executable(env!("CARGO_BIN_EXE_cool"), &cool);
    for command in ["git", "zsh"] {
        write_executable(
            fake_bin.join(command),
            "#!/bin/sh\nprintf '%s %s\\n' \"$0\" \"$*\" >> \"$COMMAND_LOG\"\n",
        );
    }
    for command in ["sym", "nvim"] {
        write_executable(
            bundle.join("binaries/usr/bin").join(command),
            "#!/bin/sh\nprintf '%s %s\\n' \"$0\" \"$*\" >> \"$COMMAND_LOG\"\n",
        );
    }

    let status = Command::new(&cool)
        .current_dir(&work_dir)
        .arg("download")
        .env("PATH", &fake_bin)
        .env("COMMAND_LOG", &command_log)
        .env("HTTPS_PROXY", "http://127.0.0.1:9")
        .env_remove("SUDO_USER")
        .status()
        .unwrap();
    assert!(status.success());
    let commands = fs::read_to_string(command_log).unwrap();
    assert!(commands.contains("git submodule update --init"));
    assert!(commands.contains("nvim --appimage-extract-and-run --headless"));
    assert!(commands.contains("zsh -c"));
}

#[test]
fn bootstraps_a_verified_release() {
    let temp = TempDir::new();
    let bundle = temp.path().join("bundle");
    let fake_bin = temp.path().join("bin");
    let asset = temp.path().join("cool-linux-x86_64");
    let checksum = temp.path().join("cool-linux-x86_64.sha256");
    fs::create_dir_all(bundle.join("scripts")).unwrap();
    fs::write(&asset, "release binary").unwrap();
    let hash = Command::new("sha256sum").arg(&asset).output().unwrap();
    let hash = String::from_utf8(hash.stdout).unwrap();
    fs::write(
        &checksum,
        format!(
            "{}  cool-linux-x86_64\n",
            hash.split_whitespace().next().unwrap()
        ),
    )
    .unwrap();
    copy_executable(
        Path::new(env!("CARGO_MANIFEST_DIR")).join("../scripts/bootstrap.sh"),
        bundle.join("scripts/bootstrap.sh"),
    );
    write_executable(
        fake_bin.join("curl"),
        "#!/bin/sh\nwhile [ $# -gt 0 ]; do\ncase $1 in\n--output) output=$2; shift 2;;\nhttp*) url=$1; shift;;\n*) shift;;\nesac\ndone\ncase $url in\n*.sha256) cp \"$BOOTSTRAP_CHECKSUM\" \"$output\";;\n*) cp \"$BOOTSTRAP_ASSET\" \"$output\";;\nesac\n",
    );

    let status = Command::new(bundle.join("scripts/bootstrap.sh"))
        .env("PATH", test_path(&fake_bin))
        .env("BOOTSTRAP_ASSET", &asset)
        .env("BOOTSTRAP_CHECKSUM", &checksum)
        .status()
        .unwrap();
    assert!(status.success());
    let installed = bundle.join("binaries/usr/bin/cool");
    assert_eq!(fs::read_to_string(installed).unwrap(), "release binary");
}

#[test]
fn runs_the_local_ubuntu_installation() {
    let temp = TempDir::new();
    let bundle = temp.path().join("bundle");
    let home = temp.path().join("home");
    let fake_bin = temp.path().join("bin");
    let command_log = temp.path().join("commands.log");
    fs::create_dir_all(bundle.join("scripts")).unwrap();
    fs::create_dir_all(&home).unwrap();
    fs::copy(
        Path::new(env!("CARGO_MANIFEST_DIR")).join("../scripts/ubuntu_install.sh"),
        bundle.join("scripts/ubuntu_install.sh"),
    )
    .unwrap();
    fs::copy(
        Path::new(env!("CARGO_MANIFEST_DIR")).join("../zshrc.example"),
        bundle.join("zshrc.example"),
    )
    .unwrap();
    write_executable(
        bundle.join("binaries/usr/bin/cool"),
        "#!/bin/sh\nprintf 'cool %s\\n' \"$*\" >> \"$COMMAND_LOG\"\n",
    );
    write_executable(fake_bin.join("id"), "#!/bin/sh\nprintf '0\\n'\n");
    write_executable(
        fake_bin.join("getent"),
        "#!/bin/sh\nprintf 'tester:x:1000:1000::%s:/bin/sh\\n' \"$TEST_HOME\"\n",
    );
    write_executable(
        fake_bin.join("apt"),
        "#!/bin/sh\nprintf 'apt %s\\n' \"$*\" >> \"$COMMAND_LOG\"\n",
    );
    write_executable(
        fake_bin.join("runuser"),
        "#!/bin/sh\nprintf 'runuser %s\\n' \"$*\" >> \"$COMMAND_LOG\"\nwhile [ \"$1\" != -- ]; do shift; done\nshift\n\"$@\"\n",
    );
    write_executable(
        fake_bin.join("chown"),
        "#!/bin/sh\nprintf 'chown %s\\n' \"$*\" >> \"$COMMAND_LOG\"\n",
    );

    let status = Command::new(bundle.join("scripts/ubuntu_install.sh"))
        .arg("local")
        .env("PATH", test_path(&fake_bin))
        .env("SUDO_USER", "tester")
        .env("TEST_HOME", &home)
        .env("COMMAND_LOG", &command_log)
        .status()
        .unwrap();
    assert!(status.success());
    assert_eq!(
        fs::read_to_string(home.join(".zshrc")).unwrap(),
        fs::read_to_string(bundle.join("zshrc.example")).unwrap()
    );
    let commands = fs::read_to_string(command_log).unwrap();
    assert!(commands.contains("apt update -qq"));
    assert!(commands.contains("apt purge -y -qqq tmux neovim"));
    assert!(commands.contains("cool --root"));
    assert!(commands.contains("install --profile local"));
}
