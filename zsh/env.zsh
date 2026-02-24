# ===
# === ENV
# ===
export GOPATH="$HOME/code/gospace"
export PATH=$PATH:$GOPATH/bin
export EDITOR="nvim"
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# rust
export PATH=$PATH:$HOME/.cargo/bin


# homebrew
# Auto-detect homebrew path for macOS and Linux
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    # Apple Silicon Mac
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    # Intel Mac
    eval "$(/usr/local/bin/brew shellenv)"
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    # Linux
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi


source $HOME/.config/zsh/zoxide.zsh


