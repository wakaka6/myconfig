# ===
# === ENV
# ===
export GOPATH="$HOME/code/gospace"
export PATH=$PATH:$GOPATH/bin
export EDITOR="nvim"
export XDG_CONFIG_HOME=$HOME/.config
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# rust
export PATH=$PATH:$HOME/.cargo/bin


# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


source $HOME/.config/zsh/zoxide.zsh


