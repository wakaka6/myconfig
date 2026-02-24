export ZIM_HOME=${XDG_CACHE_HOME:-$HOME/.cache}/zim
if [[ ! -d $ZIM_HOME ]]; then
    echo "Installing Zimfw"
    curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
    rm -f ~/.config/zsh/.zimrc
    ln -s ~/.config/zsh/zimrc ~/.config/zsh/.zimrc
fi
