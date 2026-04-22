# Omer's Cool Config
This is my personal linux config. It is suitable for installation in air gapped networks.

It contains:
* Neovim config
* zsh, git and tmux configs
* common binaries

# Installation
## In an internet-connected machine:
```sh
apt install -y git python3 make gcc zsh make
./scripts/download.py
sudo scripts/ubuntu_install.sh <local/system>
```

Local installation will install the files in your home directory and doesn't require root.
Global installation will install the configuration system-wide.
This is untested on other distros, although it should work.

## In an offline network
Unzip the zip that you received from me and run (Only ubuntu):
```sh
sudo scripts/ubuntu_install.sh <local/system>
```

# How it works
## install.py
The most important script is `./install.py`. It performs several actions:
* install - installs everything
* remove - removes everything
* auto-remove - removes previous installations of this configuration
* verify - verifies some stuff (not important)

### download.py
This script downloads the following files:
* Git submodules of this repo
	* packer.nvim - neovim's plugin manager
	* zcomet - zsh's plugin manager
	* dracula - tmux theme
* Required binaries
	* fzf - for cool CLI search and other fun things
	* exa - better ls. ls, ll and l are aliased to this
	* vim - but actually neovim. This is the more powerful sibling of vim
	* diff-so-fancy - makes git diff look so fancy
	* bat - better cat
	* tmux - latest version of tmux
* neovim plugins
	* LSP servers - the mason plugin is used to automatically download them
* zsh plugins

### install
This command does the actual installation of all the files.
It doesn't copy any files to the user's system, but instead it creates symlinks.
This have some advantages:
* The installation is instant
* It is easy to know if a file is part of the configuration
* If a file is edited outside the repo, the changes are reflected inside the repo
	* This is useful because the changes can be easily committed in git

There are 4 directories that contain partial filesystem hierarchy: neovim, zsh, binaries, misc.
The install command uses the dploy package to symlink the files.
For example, the file `binaries/usr/bin/vim` is symlinked to `/usr/bin/vim`.
In general, the file `<package>/<path>` is symlinked to `/<path>`.

The `install` command can be used to install individual packages:
```sh
scripts/install.py install -p nvim,misc
```

Available packages: misc, nvim, zsh, binaries

### remove
The remove command does the exact opposite of the install command - It removes the symlinks from the system.
Like the `install` command, it can use the `-p` switch for partial install.

## ubuntu_install.sh
The ubuntu install script is used for automated installation in ubuntu systems,
It does the following actions:
* Install some package:
	* rg - better faster grep
	* zsh - The shell. Configured by the install.py script
	* git - You need it
	* pip3 - Used to install dploy
	* dploy - Used in the `install.py` script
* Remove vim and tmux if they are installed
* Execute`install.py`
* Create `.zshrc` in user's home directory

This script is tested in ubuntu 18-24.

# Q&A
# I want to install only part of the config
It's possible. Use the -p switch of the install.py script that is described above.
If you want to install only the neovim configuration you can use the [CoolVim](https://gitlab.com/OmerSarig/coolvim) repo.

# Why the monstrous installation script (install.py)
A lot of stuff is not designed for air gapped installation.

# Known issues
* When starting tmux without a server running, it can take a few seconds
* Python-based language servers of the neovim config doesn't work if copied between machines.
* Other spooky stuff
