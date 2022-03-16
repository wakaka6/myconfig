#!/bin/bash

curPath=`readlink -f "$(dirname $0)"`
if [ ! -e "$HOME/.tmux.conf" ]
then
	ln -s "$curPath/.tmux.conf" "$HOME/.tmux.conf"
fi

if [ ! -e "$HOME/.vimrc" ]
then
	ln -s "$curPath/.vimrc" "$HOME/.vimrc"
fi

if [ ! -e "$HOME/.xprofile" ]
then
ln -s "$curPath/.xprofile" "$HOME/.xprofile"
fi

if [ ! -L "$HOME/.config/i3/config" ] 
then
	rm -f "$HOME/.config/i3/config"
    ln -s "$curPath/i3/config" "$HOME/.config/i3/config"
fi

if [ ! -L "$HOME/.config/i3status/config" ] 
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














