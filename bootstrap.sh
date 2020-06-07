#!/bin/bash

sudo apt update
sudo apt full-upgrade -y
sudo apt install -y git

if [ ! -d ~/dotfiles ]; then
    git clone https://github.com/fagnercandido/dotfiles.git ~/dotfiles
fi

~/dotfiles/install.sh
