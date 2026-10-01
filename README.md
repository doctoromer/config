# Omer's Cool Config

Personal Linux configuration for Neovim, Zsh, Git, tmux, and common command-line tools. Dependencies can be collected on a connected machine and moved as an offline bundle.

The prebuilt installer currently supports x86-64 Linux.

## Connected installation

Install the bootstrap prerequisites:

```sh
sudo apt install git zsh curl build-essential
```

Clone and prepare the repository:

```sh
git clone https://github.com/doctoromer/config.git
cd config
scripts/bootstrap.sh
binaries/usr/bin/cool download
```

Then use the Ubuntu wrapper:

```sh
sudo scripts/ubuntu_install.sh local
```

Use `system` instead of `local` to install system-wide. The wrapper installs required Ubuntu packages and creates `.zshrc` when it does not exist.

## Offline installation

A prepared bundle must contain:

- `binaries/`, including `binaries/usr/bin/cool`
- `nvim/assets/`
- `zsh/repos/`
- Initialized Git submodules

Install directly without network access:

```sh
binaries/usr/bin/cool --root "$PWD" install --profile local
```

For a system-wide installation:

```sh
sudo binaries/usr/bin/cool --root "$PWD" install --profile system
```

The Ubuntu wrapper also runs `apt`, so use it offline only when its configured package sources are available.

## Building an offline bundle

On a connected machine, run the bootstrap and download commands, then archive the populated repository:

```sh
scripts/bootstrap.sh
binaries/usr/bin/cool download
tar --exclude=.git --exclude=cool/target -czf cool-config.tar.gz .
```

## The `cool` command

`cool` locates the repository from `--root`, the current directory, or its own location under the bundle.

### Download dependencies

```sh
binaries/usr/bin/cool download
```

This downloads release binaries, initializes submodules, installs Neovim plugins and tree-sitter parsers, and downloads Zsh plugins.

### Install configuration

```sh
binaries/usr/bin/cool install --profile local
```

Available profiles are `local` and `system`. Install only selected packages with a comma-separated list:

```sh
binaries/usr/bin/cool install --profile local --packages nvim,misc
```

Available packages are `misc`, `nvim`, `zsh`, and `binaries`.

When installing from a new bundle directory, `cool` detects and removes links created by the previous bundle before creating new links.

### Remove configuration

```sh
binaries/usr/bin/cool remove --profile local
```

Use the same profile and optional package selection used during installation.

## Repository layout

- `cool/`: Rust installer source
- `binaries.json`: downloadable binary definitions
- `linkmap.toml`: local and system symlink mappings
- `nvim/`: Neovim configuration
- `zsh/`: Zsh configuration
- `misc/`: Git and tmux configuration
- `scripts/bootstrap.sh`: downloads and verifies the latest prebuilt installer
- `scripts/ubuntu_install.sh`: Ubuntu package and installation wrapper

Configuration files are linked rather than copied, so edits made through installed paths are reflected in the repository.
