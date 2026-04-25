# yabai + skhd

This setup ports the important parts of the old i3 config to macOS:

- `alt+h/j/k/l`: focus windows
- `alt+shift+h/j/k/l`: move windows in the tree
- `alt+1..0`: focus Spaces 1..10
- `alt+shift+1..0`: move the focused window to a Space
- `alt+r`: resize mode
- `alt+shift+g`: gaps mode
- `alt+return`: iTerm2
- `alt+d`: launcher

Install and start:

```sh
brew install asmvik/formulae/yabai asmvik/formulae/skhd jq
./auto_config.zsh -p yabai -p skhd install
chmod +x ~/.config/yabai/yabairc ~/.config/skhd/scripts/toggle_app.sh
yabai --start-service
skhd --start-service
```

Grant Accessibility permission to both `yabai` and `skhd` in System Settings.
Some Space-moving operations may require extra yabai scripting-addition setup on
newer macOS versions.
