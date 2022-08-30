## Install the fonts of the current directory on the system to avoid icon scrambling
1. Download nerd fonts
> Alternatively, you can download other nerd fonts
> in https://www.nerdfonts.com/font-downloads.
> The Ubuntu Nerd Font and Sauce Code Pro Nerd Font is my recommendation.

```sh
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/SourceCodePro.zip
```

2. Move the symbol font to a valid X font path. Valid font paths can be listed with `xsetq`
```sh
unzip SourceCodePro
mv *.ttf ~/.local/share/fonts/
```
3. Update font cache for the path the font was moved to (root priveleges may be needed to update cache for the system-wide paths):
```sh
fc-cache -vf ~/.local/share/fonts/
```

