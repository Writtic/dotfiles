#!/bin/bash

brew install zsh 

chsh -s $(which zsh)

brew install git stow tmux
brew install macvim --with-cscope --with-lua --HEAD --override-system-vim
brew install neovim/neovim/neovim
brew install wget thefuck

echo ":: Now run ./bootstrap.sh and follow README.md for manual setups."
