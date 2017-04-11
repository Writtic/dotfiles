#!/bin/bash

sudo apt-get install -y vim aptitude zsh

chsh -s $(which zsh)

sudo aptitude install -y git-core git \
	stow tmux wget vim-nox python-pip python-dev curl
sudo pip install thefuck
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install neovim
sudo apt-get install python3-dev python3-pip

sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor


echo ":: Now run ./setup-vim.sh and do the manual setups from README.asciidoc"

