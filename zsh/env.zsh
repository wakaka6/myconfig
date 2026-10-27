# ===
# === ENV
# ===
export GOPATH="$HOME/code/gospace"
export PATH=$PATH:$GOPATH/bin
export PATH="$HOME/.cache/.bun/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export PATH="$JAVA_HOME/bin:$PATH"
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

# omp: force Kitty graphics when the outer terminal speaks it. Env detection
# misses it inside Herdr/tmux panes, which strip TERM_PROGRAM + TERM but leave
# KITTY_PID / KITTY_INSTALLATION_DIR / TERMINFO behind. Cover direct kitty,
# ghostty, wezterm, and kitty-hosted multiplexers.
if [[ -n "$KITTY_WINDOW_ID" || "$TERM" == "xterm-kitty" || -n "$WEZTERM_PANE" || "$TERM_PROGRAM" == "ghostty" ]]; then
    export PI_FORCE_IMAGE_PROTOCOL=kitty
elif [[ "$HERDR_ENV" == "1" && ( -n "$KITTY_PID" || -n "$KITTY_INSTALLATION_DIR" || "$TERMINFO" == *kitty* ) ]]; then
    # Inside Herdr whose outer terminal is kitty.
    export PI_FORCE_IMAGE_PROTOCOL=kitty
fi

export OMO_DISABLE_POSTHOG=1
