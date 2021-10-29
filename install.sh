#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)     # dotfiles directory
olddir=~/dotfiles_old                               # old dotfiles backup directory
zshcustomsdir=~/.oh-my-zsh/custom/                  # ohmyzsh plugins directory
files="bashrc vimrc zshrc"                          # list of files/folders to symlink in homedir

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

install_oh_my_zsh () {
# Test to see if zshell is installed.  If it is:
if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Clone my oh-my-zsh repository from GitHub only if it isn't already present
    if [[ ! -d ~/.oh-my-zsh ]]; then
        export ZSH=~/.oh-my-zsh/ sh install.sh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    if [[ ! -d $zshcustomsdir/plugins/zsh-autosuggestions ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    if [[ ! -d $zshcustomsdir/plugins/zsh-syntax-highlighting ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
    if [[ ! -d $zshcustomsdir/themes/powerlevel10k ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ $CODESPACES != "true" && ! $(echo $SHELL) == $(which zsh) ]]; then
        chsh -s $(which zsh)
    fi
fi
}

install_oh_my_zsh

# move any existing dotfiles in homedir to dotfiles_old directory, then symlink new ones
echo "Moving any existing dotfiles from ~ to $olddir"
for file in $files; do
    if [[ -f ~/.$file ]];then
        echo "Moving ~/.$file to $olddir"
        mv ~/.$file ~/dotfiles_old/
    fi

    echo "Creating symlink for $dir/$file in home directory ~/.$file"
    ln -fs $dir/$file ~/.$file
done