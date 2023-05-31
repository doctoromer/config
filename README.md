# Omer's Cool Config
This is a complete and comprehensive solution for easy linux machine configuration.
It contains 4 components:
* vim configuration (Actually neovim)
* zsh configuration
* common binaries
* miscellaneous configurations (Currently git and tmux)

# Installation
## In an offline network
Unzip the zip that you received from me and run (Only ubuntu):
```sh
sudo ./ubuntu_install.sh
```
For other non-ubuntu distribution, read the script and apply to your system, It's easy.

## In an online network (A.K.A the internet)
If this is a fresh clone of this repo, first you need to download stuff.
Before running the download script, Install some commands:
```sh
sudo apt install git unzip wget zsh
```

Then, download the stuff:
```sh
./install.py download
```

Then, on ubuntu computers execute:
```sh
sudo ./ubuntu_install.sh
```

# How it works
## install.py
The most important script is `./install.py`. It performs several actions:
* download - download all required files
* install - installs everything
* remove - removes everything
* auto-remove - removes previous installations of this configuration
* verify - verifies some stuff (not important)

### download
This command downloads the following files:
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
./install.py install -p neovim,misc
```

### remove
The remove command does the exact opposite of the install command - It removes the symlinks from the system.
Like the `install` command, it can use the `-p` switch for partial install.

## ubuntu_install.sh
The ubuntu install script is used for automated installation in ubuntu systems,
It does the following actions:
* Install some package:
	* silversearcher-ag - better grep, for convenience
	* zsh - The shell. Configured by the install.py script
	* git - You need it
	* pip3 - Used to install dploy
	* dploy - Used in the `install.py` script
* Remove vim and tmux if they are installed
* Execute`install.py`
* Create `.zshrc` in user's home directory

This script is tested in ubuntu 18.

# Q&A
# I want to install only part of the config
It's possible. Use the -p switch of the install.py script that is described above.
If you want to install only the neovim configuration you can use the [CoolVim](https://gitlab.com/OmerSarig/coolvim) repo.

# Why the monstrous installation script (install.py)
This linux config is specifically designed to be used in offline (Air gapped) linux machines.
For ease of installation and portability I chose to write this (really nice and documented!) script.
If there is any better solution, I would like to hear it.

# Why a system-wide installation?
Two reasons:
1. To configure all users. It's nice to have a configured zsh and vim while in root shell.
2. To allow the user to have their own configuration files that won't be overridden between updates,
   Like ~/.config/nvim, ~/.zshrc, etc.

# Known issues
* The download process is very fragile and often breaks
* When staring tmux without a server running, it can take a few seconds
* Other spooky and odd stuff
