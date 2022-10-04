# Omer's Cool Config
This is a complete and comprehensive solution for easy linux machine configuration.
It contains 4 components:
* vim configuration (Actually neovim)
* zsh configuration
* common binaries
* miscellaneous configurations (Currently git and tmux)

# Installation
If this is a fresh clone of this repo, first you need to download stuff with:
```sh
./install.py download
```
Then, on ubuntu computers execute:
```sh
sudo ./ubuntu_install.sh
```
# How it works
## install.py
The most importent script is `./install.py`. It perfroms several actions:
* download - download all required files
* install - installs everything
* remove - removes everything
* auto-remove - removes previous installations of this configuration
* verify - verfies some stuff (not important)

### download
This command downloads the following files:
* Git submodules of this repo
	* packer.nvim - neovim's plugin manager
	* zcomet - zsh's plugin manager
	* tpm - tmux's plugin manager
* Required binaries
* neovim plugins
* tmux plugins
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
