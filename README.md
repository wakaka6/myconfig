# myconfig
This project stores the configuration files for various software under linux.It help my helped me to quickly configure my linux environment


## Quick start
Clone this project to home directory.Note that this item cannot be deleted from home.
```sh
sudo pacman -Sy git yay python3 curl wget
git clone --recursive https://github.com/wakaka6/myconfig.git $HOME/myconfig
# if on virtual machine, use the following command to clone the repo
git clone -b vm --recursive https://github.com/wakaka6/myconfig.git $HOME/myconfig
```

And then, install prerequirement software
```sh
yay -S the_silver_searcher neovim lazygit ripgrep fd delta fzf rofi 
```

File Manager
```sh
yay -S thunar
```

Beautify
```sh
sudo pacman -S picom feh variety polybar-git arc-gtk-theme papirus-icon-theme adapta-gtk-theme lxappearance arc-icon-theme
```

Reinforce i3 like bspwm to the spiral tiling 
```sh
yay -S autotiling
```

Need Font
```sh
yay -S ttf-unifont siji-git ttf-font-awesome

yay -S ttf-linux-libertine ttf-inconsolata ttf-joypixels ttf-twemoji-color noto-fonts-emoji ttf-liberation ttf-droid

# zh-CN
yay -S wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei adobe-source-han-mono-cn-fonts adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts
```

If on virtual machine, run the following command.
```sh
pacman -S open-vm-tools-desktop
```

About ranger prerequirement
```sh
pacman -S ranger highlight atool w3m poppler mediainfo ueberzug zathura-pdf-mupdf
```

About Neovim prerequirement
```sh
sudo pacman -S neovim python-pynvim
sudo pacman -S python-pip
pip install pynvim
pip install jedi
curl -sL install-node.now.sh/lts | bash
```

Software
```sh
sudo pacman -S flameshot
sudo pacman -S network-manager-applet
sudo pacman -S libreoffice-still
sudo pacman -S dunst # notify
# translation software
sudo pacman -S goldendict
sudo pacman -S translate-shell

# Input method
sudo pacman -S fcitx5-im #基础包组
sudo pacman -S fcitx5-chinese-addons #官方中文输入引擎
# sudo pacman -S fcitx5-anthy #日文输入引擎
yay -S fcitx5-pinyin-moegirl #萌娘百科词库 由于中国大陆政府对github封锁，你可能在此卡住。如卡住，可根据后文设置好代理后再安装
sudo pacman -S fcitx5-pinyin-zhwiki #中文维基百科词库
sudo pacman -S fcitx5-material-color #主题
```

In the end, run this command
```sh
cd ~/myconfig && ./auto_config.sh && reboot
```

