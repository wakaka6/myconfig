# myconfig

[English](./README.md) | 简体中文

这是我的日常终端和桌面环境 dotfiles。当前仓库同时支持 macOS 和 Arch
Linux，并通过安装 profile 区分平台，避免在 macOS 上默认安装 Linux
窗口管理器配置。

仓库建议固定放在 `$HOME/myconfig`，因为配置文件会以符号链接指回这个目录。

<div align=center> <img src=".img/demo.png" width = 100%/> </div>

## macOS

克隆仓库：

```sh
git clone --recursive https://github.com/wakaka6/myconfig.git "$HOME/myconfig"
cd "$HOME/myconfig"
```

安装基础工具：

```sh
brew install neovim tmux starship zoxide fd ripgrep fzf git-delta bat tree \
  yazi ffmpeg sevenzip poppler imagemagick chafa resvg jq \
  gitui lazygit lsd highlight atool w3m mediainfo exiftool mpv cmake go

brew install --cask ghostty kitty font-fira-code font-jetbrains-mono-nerd hammerspoon
```

安装 macOS 默认配置：

```sh
./auto_config.zsh --profile macos install
```

macOS profile 只会链接：

```text
zsh nvim tmux vimrc yazi lazygit gitui kitty ghostty herdr hammerspoon amethyst
```

它会刻意跳过 `i3`、`awesome`、`polybar`、`picom`、`rofi`、`dunst`、
`zathura`、`alacritty` 等 Linux 桌面配置，也不会配置 Claude Code。

### macOS 窗口管理

macOS 默认推荐 Amethyst 做平铺窗口管理，Hammerspoon 负责全局快捷键、
应用动作、Space 切换和输入法处理：

```sh
brew install --cask amethyst
brew install --cask hammerspoon
./auto_config.zsh -p amethyst -p hammerspoon install
open -a Amethyst
open -a Hammerspoon
```

需要在系统设置里给 Amethyst 和 Hammerspoon 授予辅助功能权限。

yabai 作为高级可选方案保留：

```sh
brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd jq
./auto_config.zsh -p yabai -p skhd install
yabai --start-service
skhd --start-service
```

启用前先看 [yabai/README.md](./yabai/README.md)。新版 macOS 上，移动窗口到
Space 等功能可能需要额外权限或 scripting addition。

## Arch Linux

克隆仓库：

```sh
sudo pacman -Sy git python3 curl wget
git clone --recursive https://github.com/wakaka6/myconfig.git "$HOME/myconfig"
```

安装常用工具：

```sh
paru -S the_silver_searcher neovim lazygit ripgrep fd delta fzf tealdeer zoxide
sudo pacman -S zsh starship lsd htop duf
```

安装 Linux 默认配置：

```sh
cd "$HOME/myconfig"
./auto_config.zsh --profile linux install
```

Linux profile 包含终端/编辑器配置，以及 `i3`、`awesome`、`polybar`、`picom`、
`rofi`、`dunst`、`zathura`、`warpd` 等 Linux 桌面配置。Claude Code 配置不在默认
profile 中，需要时手动指定安装。

桌面相关软件：

```sh
sudo pacman -S picom feh variety lxappearance kvantum polkit-gnome
paru -S polybar-git rofi alacritty xclip warpd autotiling wmfocus
sudo pacman -S awesome
```

字体：

```sh
paru -S ttf-jetbrains-mono-nerd ttf-unifont siji-git ttf-font-awesome
paru -S wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei \
  adobe-source-han-mono-cn-fonts adobe-source-han-sans-cn-fonts \
  adobe-source-han-serif-cn-fonts
```

Yazi 预览依赖：

```sh
sudo pacman -S yazi ffmpeg 7zip jq poppler imagemagick ueberzugpp
```

Neovim 依赖：

```sh
sudo pacman -S neovim python-pynvim python-pip xdotool
pip install pynvim jedi
```

可选软件：

```sh
sudo pacman -S thunar filezilla flameshot network-manager-applet libreoffice-still dunst
sudo pacman -S ranger highlight atool w3m poppler mediainfo zathura-pdf-mupdf
paru -S texlive texlive-lang biber
sudo pacman -S translate-shell remmina freerdp
```

虚拟机环境：

```sh
sudo pacman -S open-vm-tools-desktop
```

## 安装脚本用法

主要使用 zsh 版本：

```sh
./auto_config.zsh list
./auto_config.zsh --profile macos list
./auto_config.zsh --profile linux list
./auto_config.zsh -p yazi -p tmux install
```

Profiles：

- `macos`：保守的 macOS 默认配置。
- `linux`：Linux 桌面默认配置。
- `common`：跨平台终端/编辑器基础配置。
- `all`：所有已知配置项。

使用 `-p` 时会绕过 profile，只处理指定配置项。

## Claude Code

Claude Code 相关配置是可选项，不在 macOS 或 Linux 默认 profile 中。只有确定需要
这套集成时再显式安装：

```sh
./auto_config.zsh -p claude-scripts -p claude-hooks -p claude-hooks-tmux install
```
