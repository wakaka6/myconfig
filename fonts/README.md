## Install the fonts of the current directory on the system to avoid icon scrambling
1. Move the symbol font to a valid X font path. Valid font paths can be listed with `xsetq`
```sh
mv *.ttf ~/.local/share/fonts/
```
2. Update font cache for the path the font was moved to (root priveleges may be needed to update cache for the system-wide paths):
```sh
fc-cache -vf ~/.local/share/fonts/
```

