# myconfig
This project stores the configuration files for various software under linux.It help my helped me to quickly configure my linux environment


## Quick start
Clone this project to home directory.Note that this item cannot be deleted from home.
```sh
sudo pacman -Sy git yay
git clone --recursive https://github.com/wakaka6/myconfig.git $HOME
# if on virtual machine, use the following command to clone the repo
git clone -b vm --recursive https://github.com/wakaka6/myconfig.git $HOME
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
pacman -S picom feh variety polybar-git arc-gtk-theme papirus-icon-theme adapta-gtk-theme lxappearance
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
pacman -S ranger highlight atool w3m poppler mediainfo
```

In the end, run this command
```sh
cd ~/myconfig && ./auto_config.sh
```

