#!/bin/bash

curPath=`readlink -f "$(dirname $0)"`

cp -i "$curPath/.xprofile" "$HOME/.xprofile"

if [ ! -e "$HOME/.tmux.conf" ]
then
	ln -s "$curPath/.tmux.conf" "$HOME/.tmux.conf"
fi

if [ ! -e "$HOME/.vimrc" ]
then
	ln -s "$curPath/.vimrc" "$HOME/.vimrc"
fi


if [ ! -L "$HOME/.config/i3" ] 
then
	rm -fr "$HOME/.config/i3"
    ln -s "$curPath/i3" "$HOME/.config/i3"
fi

if [ -d "$HOME/.config/i3status" -a ! -L "$HOME/.config/i3status/config" ] 
then
	rm -f "$HOME/.config/i3status/config"
	ln -s "$curPath/i3status/config" "$HOME/.config/i3status/config"
fi

if [ ! -e "$HOME/.config/nvim" ] 
then
	ln -s "$curPath/nvim" "$HOME/.config/nvim"
fi


if [ ! -e "$HOME/.config/ranger" ] 
then
	ln -s "$curPath/ranger" "$HOME/.config/ranger"
fi



if [ ! -L "$HOME/.config/lazygit/config.yml" ] 
then
	rm -f "$HOME/.config/lazygit/config.yml"
    ln -s "$curPath/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
fi



if [ ! -d "$HOME/.config/zsh" -a ! -L "$HOME/.config/zsh" ] 
then
	rm -fr "$HOME/.config/zsh"
    ln -s "$curPath/zsh" "$HOME/.config/zsh"
fi


if [ -d "$HOME/.config/dunst" -a ! -e "$HOME/.config/dunst/dunstrc" ] 
then
    cp "$curPath/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
fi

if [ ! -d "$HOME/.oh-my-zsh" ] 
then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi


cp -i "$curPath/zsh/zshrc" "$curPath/zsh/.zshrc"





