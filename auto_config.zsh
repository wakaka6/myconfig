#!/usr/bin/env zsh
# Auto Configuration Script - A modular approach to dotfile management
# Author: Auto Config Manager
# Version: 3.2.0 - Zsh version (works on macOS and Linux)

set -eo pipefail

# ============================================================================
# Configuration Section
# ============================================================================

readonly SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_NAME="${0:t}"
readonly BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
readonly LOG_FILE="/tmp/auto-config-$(date +%Y%m%d-%H%M%S).log"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Global flags
FORCE_MODE=false
SELECTED_PLUGINS=()
PROFILE=""

# Standard symlink configurations: source -> target
typeset -A CONFIG_ITEMS=(
    [i3]="$HOME/.config/i3"
    [i3status]="$HOME/.config/i3status"
    [nvim]="$HOME/.config/nvim"
    [zathura]="$HOME/.config/zathura"
    [latexmk]="$HOME/.config/latexmk"
    [ranger]="$HOME/.config/ranger"
    [alacritty]="$HOME/.config/alacritty"
    [kitty]="$HOME/.config/kitty"
    [zsh]="$HOME/.config/zsh"
    [rofi]="$HOME/.config/rofi"
    [dunst]="$HOME/.config/dunst"
    [picom]="$HOME/.config/picom"
    [yazi]="$HOME/.config/yazi"
    [gitui]="$HOME/.config/gitui"
    [awesome]="$HOME/.config/awesome"
    [polybar]="$HOME/.config/polybar"
    [yabai]="$HOME/.config/yabai"
    [skhd]="$HOME/.config/skhd"
    [hammerspoon]="$HOME/.hammerspoon"
)

# Special configurations: name -> "type:source:target"
# Types: symlink, copy, generate, merge
typeset -A SPECIAL_CONFIGS=(
    [lazygit]="symlink:lazygit/config.yml:$HOME/.config/lazygit/config.yml"
    [herdr]="symlink:herdr/config.toml:$HOME/.config/herdr/config.toml"
    [ghostty]="symlink:ghostty/config.ghostty:$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
    [tmux]="symlink:.tmux.conf:$HOME/.tmux.conf"
    [vimrc]="symlink:.vimrc:$HOME/.vimrc"
    [amethyst]="symlink:amethyst/amethyst.yml:$HOME/.amethyst.yml"
    [xprofile]="copy:.xprofile:$HOME/.xprofile"
    [scratchpad]="generate:scratchpad_content:$HOME/Documents/scratchpad/CLAUDE.md"
    [warpd]="symlink:warpd/config:$HOME/.config/warpd/config"
    [claude-scripts]="symlink:claude/scripts:$HOME/.claude/scripts"
    [claude-hooks]="merge:claude/hooks.json:$HOME/.claude/settings.json"
    [claude-hooks-tmux]="merge:claude/hooks-tmux.json:$HOME/.claude/settings.json"
)

profile_for_platform() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux) echo "linux" ;;
        *) echo "common" ;;
    esac
}

profile_contains() {
    local profile=$1
    local plugin=$2

    case "$profile" in
        macos)
            [[ " zsh nvim tmux vimrc yazi lazygit gitui kitty ghostty herdr hammerspoon amethyst " == *" $plugin "* ]]
            ;;
        linux)
            [[ " zsh nvim tmux vimrc yazi lazygit gitui kitty herdr i3 i3status awesome polybar picom rofi dunst zathura ranger latexmk alacritty xprofile warpd scratchpad " == *" $plugin "* ]]
            ;;
        common)
            [[ " zsh nvim tmux vimrc yazi lazygit gitui kitty herdr " == *" $plugin "* ]]
            ;;
        all)
            return 0
            ;;
        *)
            log ERROR "Unknown profile: $profile"
            return 1
            ;;
    esac
}

# ============================================================================
# Utility Functions
# ============================================================================

log() {
    local level=$1
    shift
    local message="$*"

    case "$level" in
        INFO)    print -P "${BLUE}[INFO]${NC} $message" | tee -a "$LOG_FILE" ;;
        SUCCESS) print -P "${GREEN}[SUCCESS]${NC} $message" | tee -a "$LOG_FILE" ;;
        WARN)    print -P "${YELLOW}[WARN]${NC} $message" | tee -a "$LOG_FILE" ;;
        ERROR)   print -P "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE" ;;
    esac
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a plugin is selected (or if no plugins specified, return true)
is_plugin_selected() {
    local plugin=$1
    if [[ ${#SELECTED_PLUGINS[@]} -eq 0 ]]; then
        profile_contains "$PROFILE" "$plugin"
        return $?
    fi
    for p in "${SELECTED_PLUGINS[@]}"; do
        if [[ "$p" == "$plugin" ]]; then
            return 0
        fi
    done
    return 1
}

# Get all available plugin names
get_all_plugins() {
    {
        print -l "${(k)CONFIG_ITEMS[@]}"
        print -l "${(k)SPECIAL_CONFIGS[@]}"
    } | sort -u
}

# Ask user for confirmation, returns 0 for yes, 1 for no
# In force mode, always returns 0
confirm() {
    local message=$1

    if [[ "$FORCE_MODE" == "true" ]]; then
        return 0
    fi

    read -q "REPLY?$message [y/N] "
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        log INFO "Created backup directory: $BACKUP_DIR"
    fi
}

backup_config() {
    local source=$1
    local name=${source:t}

    if [[ -e "$source" && ! -L "$source" ]]; then
        create_backup_dir
        cp -r "$source" "$BACKUP_DIR/$name"
        log INFO "Backed up $source to $BACKUP_DIR/$name"
        return 0
    fi
    return 1
}

# Cross-platform readlink -f
resolve_path() {
    local path=$1
    if [[ -e "$path" ]]; then
        # Use zsh built-in :A modifier for absolute path resolution
        echo "${path:A}"
    else
        echo "$path"
    fi
}

# ============================================================================
# Core Operations
# ============================================================================

# Create symbolic link with proper checks and user confirmation
create_symlink() {
    local source=$1
    local target=$2

    # Check if source exists
    if [[ ! -e "$source" ]]; then
        log ERROR "Source does not exist: $source"
        return 1
    fi

    # Handle existing target
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_source
            current_source=$(resolve_path "$target")
            if [[ "$current_source" == "$(resolve_path "$source")" ]]; then
                log INFO "Already linked correctly: $target"
                return 0
            fi
            log WARN "Existing symlink points to: $current_source"
        else
            log WARN "Target exists: $target"
        fi

        if confirm "Overwrite $target?"; then
            if [[ ! -L "$target" ]]; then
                backup_config "$target"
            fi
            rm -rf "$target"
            log INFO "Removed existing: $target"
        else
            log INFO "Skipped: $target"
            return 0
        fi
    fi

    # Create parent directory if needed
    local target_dir=${target:h}
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        log INFO "Created directory: $target_dir"
    fi

    ln -s "$source" "$target"
    log SUCCESS "Created symlink: $target -> $source"
}

# Copy file with user confirmation
copy_file() {
    local source=$1
    local target=$2

    if [[ ! -f "$source" ]]; then
        log WARN "Source file not found: $source"
        return 1
    fi

    if [[ -e "$target" ]]; then
        if confirm "Overwrite $target?"; then
            backup_config "$target"
        else
            log INFO "Skipped: $target"
            return 0
        fi
    fi

    local target_dir=${target:h}
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
    fi

    cp "$source" "$target"
    log SUCCESS "Copied: $source -> $target"
}

# Generate file with content from a function
generate_file() {
    local content_func=$1
    local target=$2

    local target_dir=${target:h}
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        log SUCCESS "Created directory: $target_dir"
    fi

    if [[ -f "$target" ]]; then
        if confirm "Overwrite $target?"; then
            backup_config "$target"
        else
            log INFO "Skipped: $target"
            return 0
        fi
    fi

    $content_func > "$target"
    log SUCCESS "Generated: $target"
}

# Merge JSON file into target (deep merge)
merge_json() {
    local source=$1
    local target=$2

    if [[ ! -f "$source" ]]; then
        log ERROR "Source JSON not found: $source"
        return 1
    fi

    if ! command_exists jq; then
        log ERROR "jq is required for JSON merge. Please install jq."
        return 1
    fi

    local target_dir=${target:h}
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        log SUCCESS "Created directory: $target_dir"
    fi

    if [[ -f "$target" ]]; then
        # Deep merge: source overwrites target for matching keys
        local merged
        merged=$(jq -s '.[0] * .[1]' "$target" "$source" 2>/dev/null)
        if [[ $? -eq 0 && -n "$merged" ]]; then
            backup_config "$target"
            echo "$merged" > "$target"
            log SUCCESS "Merged: $source -> $target"
        else
            log ERROR "Failed to merge JSON files"
            return 1
        fi
    else
        # Target doesn't exist, just copy the source
        cp "$source" "$target"
        log SUCCESS "Created: $target (from $source)"
    fi
}

# ============================================================================
# Content Generators
# ============================================================================

scratchpad_content() {
    cat << 'EOF'
# Scratchpad 工作目录

这是用户的个人笔记和思考记录目录。记录瞬间的想法、灵感

## 目录结构

```
~/Documents/scratchpad/
├── CLAUDE.md          # 本说明文件
├── 2025-12-03/        # 日期子目录
│   └── 2025-12-03-note.md
├── 2025-12-04/
│   └── 2025-12-04-note.md
└── ...
```

每天的笔记存放在对应日期的子目录中，格式：`YYYY-MM-DD/YYYY-MM-DD-note.md`
对应子目录可能还包含其他相关资源文件。

## Claude 助理指南

作为用户的 AI 助理，请遵循以下原则：

1. **尊重隐私**：这里的内容是用户的私人思考，不要在没有明确请求时主动评判
2. **理解上下文**：阅读相关笔记以更好地理解用户的需求和背景
3. **简洁回复**：用户通常在快速记录或查询，保持回复精炼
4. **中文优先**：用户习惯使用中文交流

## 常见任务

- 帮助整理和归纳笔记
- 回答技术问题
- 协助代码调试
- 头脑风暴和想法扩展
EOF
}

# ============================================================================
# Main Functions
# ============================================================================

install_configs() {
    log INFO "Starting configuration installation..."
    log INFO "Script directory: $SCRIPT_DIR"
    log INFO "Force mode: $FORCE_MODE"
    log INFO "Profile: $PROFILE"
    if [[ ${#SELECTED_PLUGINS[@]} -gt 0 ]]; then
        log INFO "Selected plugins: ${SELECTED_PLUGINS[*]}"
    fi

    # Process standard configurations
    for config in "${(k)CONFIG_ITEMS[@]}"; do
        if ! is_plugin_selected "$config"; then
            continue
        fi
        local source="$SCRIPT_DIR/$config"
        local target="${CONFIG_ITEMS[$config]}"
        log INFO "Processing $config..."
        create_symlink "$source" "$target"
    done

    # Process special configurations
    for config in "${(k)SPECIAL_CONFIGS[@]}"; do
        if ! is_plugin_selected "$config"; then
            continue
        fi
        log INFO "Processing special config: $config..."
        local spec="${SPECIAL_CONFIGS[$config]}"
        local type="${spec%%:*}"
        local rest="${spec#*:}"
        local source_part="${rest%%:*}"
        local target="${rest#*:}"

        case "$type" in
            symlink)
                create_symlink "$SCRIPT_DIR/$source_part" "$target"
                ;;
            copy)
                copy_file "$SCRIPT_DIR/$source_part" "$target"
                ;;
            generate)
                generate_file "$source_part" "$target"
                ;;
            merge)
                merge_json "$SCRIPT_DIR/$source_part" "$target"
                ;;
            *)
                log ERROR "Unknown config type: $type"
                ;;
        esac
    done

    # Install oh-my-zsh if not present (only when zsh is selected or no filter)
    if is_plugin_selected "zsh" && [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        if confirm "Install Oh My Zsh?"; then
            if command_exists curl; then
                sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
                log SUCCESS "Oh My Zsh installed"
            else
                log ERROR "curl not found. Please install curl first"
            fi
        fi
    fi

    log SUCCESS "Configuration installation completed!"
    log INFO "Log file: $LOG_FILE"
}

uninstall_configs() {
    log INFO "Starting configuration removal..."
    log INFO "Profile: $PROFILE"
    if [[ ${#SELECTED_PLUGINS[@]} -gt 0 ]]; then
        log INFO "Selected plugins: ${SELECTED_PLUGINS[*]}"
    fi

    # Remove standard configurations
    for config in "${(k)CONFIG_ITEMS[@]}"; do
        if ! is_plugin_selected "$config"; then
            continue
        fi
        local target="${CONFIG_ITEMS[$config]}"
        if [[ -L "$target" ]]; then
            rm -f "$target"
            log SUCCESS "Removed symlink: $target"
        else
            log INFO "Not a symlink, skipping: $target"
        fi
    done

    # Remove special configurations
    for config in "${(k)SPECIAL_CONFIGS[@]}"; do
        if ! is_plugin_selected "$config"; then
            continue
        fi
        local spec="${SPECIAL_CONFIGS[$config]}"
        local type="${spec%%:*}"
        local rest="${spec#*:}"
        local target="${rest#*:}"

        case "$type" in
            symlink)
                if [[ -L "$target" ]]; then
                    rm -f "$target"
                    log SUCCESS "Removed symlink: $target"
                fi
                ;;
            copy|generate)
                if [[ -f "$target" ]]; then
                    if confirm "Remove $target?"; then
                        rm -f "$target"
                        log SUCCESS "Removed: $target"
                    fi
                fi
                ;;
            merge)
                log WARN "Merge config '$config' cannot be auto-removed from $target"
                log INFO "Please manually remove the merged content if needed"
                ;;
        esac
    done

    log SUCCESS "Configuration removal completed!"
}

show_status() {
    log INFO "Configuration Status Report"
    log INFO "Profile: $PROFILE"
    echo "===================================="
    echo "Standard Configurations:"

    local config source target status_msg link_target
    for config in "${(k)CONFIG_ITEMS[@]}"; do
        if ! is_plugin_selected "$config"; then
            continue
        fi
        source="$SCRIPT_DIR/$config"
        target="${CONFIG_ITEMS[$config]}"

        if [[ -L "$target" ]]; then
            link_target=$(resolve_path "$target")
            if [[ "$link_target" == "$(resolve_path "$source")" ]]; then
                status_msg="${GREEN}✓ Linked${NC}"
            else
                status_msg="${YELLOW}⚠ Linked to different source${NC}"
            fi
        elif [[ -e "$target" ]]; then
            status_msg="${YELLOW}⚠ Exists but not linked${NC}"
        else
            status_msg="${RED}✗ Not configured${NC}"
        fi
        printf "  %-15s: %b\n" "$config" "$status_msg"
    done

    echo "------------------------------------"
    echo "Special Configurations:"

    local spec type rest source_part expected
    for config in "${(k)SPECIAL_CONFIGS[@]}"; do
        if ! is_plugin_selected "$config"; then
            continue
        fi
        spec="${SPECIAL_CONFIGS[$config]}"
        type="${spec%%:*}"
        rest="${spec#*:}"
        source_part="${rest%%:*}"
        target="${rest#*:}"

        case "$type" in
            symlink)
                if [[ -L "$target" ]]; then
                    link_target=$(resolve_path "$target")
                    expected="$SCRIPT_DIR/$source_part"
                    if [[ "$link_target" == "$(resolve_path "$expected")" ]]; then
                        status_msg="${GREEN}✓ Linked${NC}"
                    else
                        status_msg="${YELLOW}⚠ Linked to different source${NC}"
                    fi
                elif [[ -e "$target" ]]; then
                    status_msg="${YELLOW}⚠ Exists but not linked${NC}"
                else
                    status_msg="${RED}✗ Not configured${NC}"
                fi
                ;;
            copy|generate)
                if [[ -f "$target" ]]; then
                    status_msg="${GREEN}✓ Present${NC}"
                else
                    status_msg="${RED}✗ Not present${NC}"
                fi
                ;;
            merge)
                if [[ -f "$target" ]]; then
                    # Check if hooks key exists in target
                    if command_exists jq && jq -e '.hooks' "$target" >/dev/null 2>&1; then
                        status_msg="${GREEN}✓ Merged${NC}"
                    else
                        status_msg="${YELLOW}⚠ Target exists but hooks not merged${NC}"
                    fi
                else
                    status_msg="${RED}✗ Target not present${NC}"
                fi
                ;;
        esac
        printf "  %-15s: %b\n" "$config" "$status_msg"
    done

    echo "===================================="
}

show_plugins() {
    echo "Profile: $PROFILE"
    echo "Standard configurations:"
    for config in "${(ok)CONFIG_ITEMS[@]}"; do
        if is_plugin_selected "$config"; then
            echo "  $config"
        fi
    done
    echo "Special configurations:"
    for config in "${(ok)SPECIAL_CONFIGS[@]}"; do
        if is_plugin_selected "$config"; then
            local spec="${SPECIAL_CONFIGS[$config]}"
            local type="${spec%%:*}"
            echo "  $config ($type)"
        fi
    done
}

show_help() {
    local std_plugins=$(print -l "${(k)CONFIG_ITEMS[@]}" | sort | sed 's/^/    /')
    local special_plugins=$(for p in "${(k)SPECIAL_CONFIGS[@]}"; do
        local spec="${SPECIAL_CONFIGS[$p]}"
        local type="${spec%%:*}"
        echo "    $p ($type)"
    done | sort)

    cat << EOF
Auto Configuration Manager v3.2.0 (zsh)

USAGE:
    $SCRIPT_NAME [OPTIONS] [COMMAND]

COMMANDS:
    install     Install all configurations (default)
    uninstall   Remove all symlinks and generated files
    status      Show current configuration status
    list        List configurations selected by the active profile/filter
    help        Show this help message

OPTIONS:
    -f, --force             Force overwrite without asking
    -p, --plugin <name>     Only process specified plugin(s), can be used multiple times
    --profile <name>        Use profile: macos, linux, common, all
    -h, --help              Show this help message

AVAILABLE PLUGINS:
  Standard (symlink to ~/.config/):
$std_plugins

  Special:
$special_plugins

EXAMPLES:
    $SCRIPT_NAME                          # Install current platform profile
    $SCRIPT_NAME --profile macos install  # Install macOS-safe defaults
    $SCRIPT_NAME --profile linux install  # Install Linux desktop defaults
    $SCRIPT_NAME --profile all install    # Install every known configuration
    $SCRIPT_NAME -p nvim -p zsh install   # Install only nvim and zsh
    $SCRIPT_NAME --profile macos list     # List macOS defaults
    $SCRIPT_NAME -p awesome status        # Check status of awesome only
    $SCRIPT_NAME uninstall                # Remove all configurations

BACKUP:
    Existing configurations are backed up to: ~/.config-backup-<timestamp>

LOG:
    Installation logs are saved to: /tmp/auto-config-<timestamp>.log

EOF
}

# ============================================================================
# Main Script Logic
# ============================================================================

main() {
    local command="install"
    PROFILE="$(profile_for_platform)"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force)
                FORCE_MODE=true
                shift
                ;;
            -p|--plugin)
                if [[ -z "${2:-}" ]]; then
                    log ERROR "Missing plugin name after $1"
                    exit 1
                fi
                SELECTED_PLUGINS+=("$2")
                shift 2
                ;;
            --profile)
                if [[ -z "${2:-}" ]]; then
                    log ERROR "Missing profile name after $1"
                    exit 1
                fi
                PROFILE="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            install|uninstall|status|list|help)
                command=$1
                shift
                ;;
            *)
                log ERROR "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    case "$command" in
        install)
            install_configs
            ;;
        uninstall)
            if confirm "Are you sure you want to uninstall configurations?"; then
                uninstall_configs
            else
                log INFO "Uninstall cancelled"
            fi
            ;;
        status)
            show_status
            ;;
        list)
            show_plugins
            ;;
        help)
            show_help
            ;;
    esac
}

main "$@"
