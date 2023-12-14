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


if [ ! -e "$HOME/.config/zathura" ]
then
	ln -s "$curPath/zathura" "$HOME/.config/zathura"
fi

if [ ! -e "$HOME/.config/latexmk" ]
then
	ln -s "$curPath/latexmk" "$HOME/.config/latexmk"
fi

if [ ! -e "$HOME/.config/ranger" ]
then
	ln -s "$curPath/ranger" "$HOME/.config/ranger"
fi


if [ ! -e "$HOME/.config/alacritty" ]
then
	ln -s "$curPath/alacritty" "$HOME/.config/alacritty"
fi

if [ ! -e "$HOME/.config/kitty" ]
then
	ln -s "$curPath/kitty" "$HOME/.config/kitty"
fi

if [ ! -L "$HOME/.config/lazygit/config.yml" ]
then
    if [ ! -e "$HOME/.config/lazygit" ]
    then 
        mkdir $HOME/.config/lazygit
    fi
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

if [ ! -e "$HOME/.config/rofi" ]
then
	ln -s "$curPath/rofi" "$HOME/.config/rofi"
fi

if [ ! -e "$HOME/.config/dunst" ]
then
	ln -s "$curPath/dunst" "$HOME/.config/dunst"
fi

if [ ! -e "$HOME/.config/picom" ]
then
	ln -s "$curPath/picom" "$HOME/.config/picom"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]
then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi


cp -i "$curPath/zsh/zshrc" "$curPath/zsh/.zshrc"





