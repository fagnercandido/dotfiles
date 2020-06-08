#!/bin/sh

BASEDIR=$(dirname "$0")
cd $BASEDIR

git pull

taskshell() {
    echo '
    ----------
    - Shell
    ----------
    '
    sudo apt update
    sudo apt -y full-upgrade
    sudo apt install -y aptitude
    sudo aptitude install -y `cat dependencies.txt`

    # Change the shell to zsh
	echo "[INFO] Changing the shell of this user to use zsh...";
	chsh -s $(which zsh)

    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
}

tasksnap() {
    echo '
    ----------
    - Snap
    ----------
    '
    sudo snap refresh
    sudo snap install code --classic
    sudo snap install skype --classic
    sudo snap install spotify
    sudo snap install exercism
    sudo snap install insomnia
}

tasktmux(){
    echo '
    ----------
    - Tmux
    ----------
    '
    ln -sf $BASEDIR/tmux.conf ~/.tmux.conf
}

taskzsh(){
    echo '
    ----------
    - ZSH
    ----------
    '
    # Install Oh My Zsh!
	echo "[INFO] Installing Oh My Zsh...";
	curl -L http://install.ohmyz.sh | sh
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-custom/plugins/zsh-syntax-highlighting
    
    
    echo 'Installing Zinit'
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

    ln -sf $BASEDIR/zshrc ~/.zshrc
}

taskfzf(){
    echo '
    ----------
    - FZF
    ----------
    '
    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi
    git -C ~/.fzf pull
    ~/.fzf/install --all
}

taskvim(){
    echo '
    ----------
    - VIM
    ----------
    '
    rm -rf ~/.vimrc
    ln -s $BASEDIR/vimrc ~/.vimrc

    if [ ! -d ~/.vim ]; then
        vim +PlugInstall +qall
    fi

    vim +PlugUpgrade +qall
    vim +PlugUpdate +qall

    cd ~/.vim/plugged/YouCompleteMe
    ./install.py --tern-completer --js-completer --java-completer
}

taskasdf() {
	echo '
    ----------
    - ASDF
    ----------
    '
	echo "[INFO] Cloning asdf repository...";
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf;

	echo '. $HOME/.asdf/asdf.sh' >> ~/.zshrc
	echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc

    echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
	echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc

    source $HOME/.asdf/asdf.sh;
	source ~/.zshrc
    source ~/.bashrc

	# Install required software for ASDF builds
	echo "[INFO] Installing required software for ASDF builds...";
	sudo apt-get install -y git-core curl wget build-essential autoconf unzip libssl-dev libncurses5-dev libreadline-dev zlib1g-dev libsqlite3-dev inotify-tools pkg-config

	# Install useful plugins (at least for me :D)
	echo "[INFO] Installing asdf plugins...";
    
    source ~/.zshrc
    source ~/.bashrc

	asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git;
	asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git;
	bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring;
	asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git;
	asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git;
	asdf plugin-add java https://github.com/halcyon/asdf-java.git;
    asdf plugin-add golang https://github.com/kennyp/asdf-golang.git;
    asdf plugin-add gradle https://github.com/rfrancis/asdf-gradle.git;
    asdf plugin-add maven;
}

if [ $# -eq 0 ]; then
    taskshell
    tasksnap
    tasktmux
    taskzsh
    taskfzf
    taskvim
    taskasdf
fi

for PARAM in $*
do
    case $PARAM in

        'shell')
            taskshell
            ;;
        'snap')
            tasksnap
            ;;
        'tmux')
            tasktmux
            ;;
        'zsh')
            taskzsh
            ;;
        'fzf')
            taskfzf
            ;;
        'vim')
            taskvim
            ;;
        'asdf')
            taskasdf
            ;;
        *)
            echo "This option doens't exist! " $PARAM "\n"
            ;;
    esac
done
