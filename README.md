# myconfig

English | [简体中文](./README_CN.md)

Dotfiles for my daily terminal and desktop setup. The repository now supports
both macOS and Arch Linux; each platform has its own install profile so Linux
window-manager configs are not installed on macOS by default.

The repo is expected to live at `$HOME/myconfig` because most config symlinks
point back into this directory.

<div align=center> <img src=".img/demo.png" width = 100%/> </div>

## macOS

Clone the repo:

```sh
git clone --recursive https://github.com/wakaka6/myconfig.git "$HOME/myconfig"
cd "$HOME/myconfig"
```

Install the core tools:

```sh
brew install neovim tmux starship zoxide fd ripgrep fzf git-delta bat tree \
  yazi ffmpeg sevenzip poppler imagemagick chafa resvg jq \
  gitui lazygit lsd highlight atool w3m mediainfo exiftool mpv cmake go

brew install --cask kitty font-jetbrains-mono-nerd
```

Install the default macOS config profile:

```sh
./auto_config.zsh --profile macos install
```

The macOS profile links only:

```text
zsh nvim tmux vimrc yazi lazygit gitui kitty skhd amethyst
```

It intentionally skips Linux desktop configs such as `i3`, `awesome`, `polybar`,
`picom`, `rofi`, `dunst`, `zathura`, and `alacritty`, and it does not configure
Claude Code.

### macOS Window Management

The recommended macOS setup is Amethyst for tiling plus skhd for application and
Space shortcuts:

```sh
brew install --cask amethyst
brew install koekeishiya/formulae/skhd
./auto_config.zsh -p amethyst -p skhd install
skhd --start-service
open -a Amethyst
```

Grant Accessibility permission to Amethyst and skhd in System Settings.

yabai is available as an advanced optional setup:

```sh
brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd jq
./auto_config.zsh -p yabai -p skhd install
yabai --start-service
skhd --start-service
```

See [yabai/README.md](./yabai/README.md) before enabling it, especially on newer
macOS versions where Space-moving features may need extra permissions or the
scripting addition.

## Arch Linux

Clone the repo:

```sh
sudo pacman -Sy git python3 curl wget
git clone --recursive https://github.com/wakaka6/myconfig.git "$HOME/myconfig"
```

Install common tools:

```sh
paru -S the_silver_searcher neovim lazygit ripgrep fd delta fzf tealdeer zoxide
sudo pacman -S zsh starship lsd htop duf
```

Install the default Linux profile:

```sh
cd "$HOME/myconfig"
./auto_config.zsh --profile linux install
```

The Linux profile includes the terminal/editor configs and Linux desktop pieces
such as `i3`, `awesome`, `polybar`, `picom`, `rofi`, `dunst`, `zathura`, and
`warpd`. Claude Code config is not part of the default profile; install those
entries explicitly if needed.

Desktop packages:

```sh
sudo pacman -S picom feh variety lxappearance kvantum polkit-gnome
paru -S polybar-git rofi alacritty xclip warpd autotiling wmfocus
sudo pacman -S awesome
```

Fonts:

```sh
paru -S ttf-jetbrains-mono-nerd ttf-unifont siji-git ttf-font-awesome
paru -S wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei \
  adobe-source-han-mono-cn-fonts adobe-source-han-sans-cn-fonts \
  adobe-source-han-serif-cn-fonts
```

Yazi preview dependencies:

```sh
sudo pacman -S yazi ffmpeg 7zip jq poppler imagemagick ueberzugpp
```

Neovim dependencies:

```sh
sudo pacman -S neovim python-pynvim python-pip xdotool
pip install pynvim jedi
```

Optional software:

```sh
sudo pacman -S thunar filezilla flameshot network-manager-applet libreoffice-still dunst
sudo pacman -S ranger highlight atool w3m poppler mediainfo zathura-pdf-mupdf
paru -S texlive texlive-lang biber
sudo pacman -S translate-shell remmina freerdp
```

If running in a virtual machine:

```sh
sudo pacman -S open-vm-tools-desktop
```

## Installer Usage

The zsh installer is the primary script:

```sh
./auto_config.zsh list
./auto_config.zsh --profile macos list
./auto_config.zsh --profile linux list
./auto_config.zsh -p yazi -p tmux install
```

Profiles:

- `macos`: conservative macOS defaults.
- `linux`: Linux desktop defaults.
- `common`: terminal/editor-only shared defaults.
- `all`: every known config entry.

Use `-p` to bypass the profile and install only specific entries.

## Claude Code

Claude Code-related config is optional and not installed by the macOS or Linux
default profiles. Install it explicitly only on machines where you want this
integration:

```sh
./auto_config.zsh -p claude-scripts -p claude-hooks -p claude-hooks-tmux install
```
