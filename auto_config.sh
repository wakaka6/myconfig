#!/usr/bin/env bash
# Auto Configuration Script - A modular approach to dotfile management
# Author: Auto Config Manager
# Version: 2.0.0

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# Configuration Section
# ============================================================================

# Script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
readonly LOG_FILE="/tmp/auto-config-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration items - Easy to add/remove/modify
declare -A CONFIG_ITEMS=(
    ["i3"]="$HOME/.config/i3"
    ["i3status"]="$HOME/.config/i3status"
    ["nvim"]="$HOME/.config/nvim"
    ["zathura"]="$HOME/.config/zathura"
    ["latexmk"]="$HOME/.config/latexmk"
    ["ranger"]="$HOME/.config/ranger"
    ["alacritty"]="$HOME/.config/alacritty"
    ["kitty"]="$HOME/.config/kitty"
    ["zsh"]="$HOME/.config/zsh"
    ["rofi"]="$HOME/.config/rofi"
    ["dunst"]="$HOME/.config/dunst"
    ["picom"]="$HOME/.config/picom"
    ["yazi"]="$HOME/.config/yazi"
    ["gitui"]="$HOME/.config/gitui"
)

# Special configurations that need custom handling
declare -A SPECIAL_CONFIGS=(
    ["lazygit"]="lazygit_setup"
    ["xprofile"]="xprofile_setup"
    ["tmux"]="tmux_setup"
    ["vimrc"]="vimrc_setup"
)

# ============================================================================
# Utility Functions
# ============================================================================

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        INFO)  echo -e "${BLUE}[INFO]${NC} $message" | tee -a "$LOG_FILE" ;;
        SUCCESS) echo -e "${GREEN}[SUCCESS]${NC} $message" | tee -a "$LOG_FILE" ;;
        WARN)  echo -e "${YELLOW}[WARN]${NC} $message" | tee -a "$LOG_FILE" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE" ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create backup directory
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        log INFO "Created backup directory: $BACKUP_DIR"
    fi
}

# Backup existing configuration
backup_config() {
    local source=$1
    local name=$(basename "$source")
    
    if [[ -e "$source" && ! -L "$source" ]]; then
        create_backup_dir
        cp -r "$source" "$BACKUP_DIR/$name"
        log INFO "Backed up $source to $BACKUP_DIR/$name"
        return 0
    fi
    return 1
}

# Create symbolic link with proper checks
create_symlink() {
    local source=$1
    local target=$2
    local force=${3:-false}
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        log ERROR "Source does not exist: $source"
        return 1
    fi
    
    # Handle existing target
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_source=$(readlink -f "$target" 2>/dev/null || echo "unknown")
            if [[ "$current_source" == "$source" ]]; then
                log INFO "Already linked correctly: $target -> $source"
                return 0
            else
                log WARN "Existing symlink points elsewhere: $target -> $current_source"
                if [[ "$force" == "true" ]]; then
                    rm -f "$target"
                    log INFO "Removed existing symlink: $target"
                else
                    return 1
                fi
            fi
        else
            # Regular file/directory exists
            if backup_config "$target"; then
                rm -rf "$target"
                log INFO "Removed original: $target"
            else
                log ERROR "Failed to backup $target"
                return 1
            fi
        fi
    fi
    
    # Create parent directory if needed
    local target_dir=$(dirname "$target")
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        log INFO "Created directory: $target_dir"
    fi
    
    # Create the symlink
    ln -s "$source" "$target"
    log SUCCESS "Created symlink: $target -> $source"
    return 0
}

# ============================================================================
# Special Configuration Handlers
# ============================================================================

lazygit_setup() {
    local source="$SCRIPT_DIR/lazygit/config.yml"
    local target="$HOME/.config/lazygit/config.yml"
    create_symlink "$source" "$target"
}

xprofile_setup() {
    local source="$SCRIPT_DIR/.xprofile"
    local target="$HOME/.xprofile"
    
    if [[ -f "$source" ]]; then
        cp -i "$source" "$target" 2>/dev/null || {
            log WARN "Skipped .xprofile (user chose not to overwrite)"
            return 1
        }
        log SUCCESS "Copied .xprofile to $HOME"
    else
        log WARN ".xprofile not found in $SCRIPT_DIR"
    fi
}

tmux_setup() {
    local source="$SCRIPT_DIR/.tmux.conf"
    local target="$HOME/.tmux.conf"
    
    if [[ -f "$source" ]]; then
        create_symlink "$source" "$target"
    else
        log WARN ".tmux.conf not found in $SCRIPT_DIR"
    fi
}

vimrc_setup() {
    local source="$SCRIPT_DIR/.vimrc"
    local target="$HOME/.vimrc"
    
    if [[ -f "$source" ]]; then
        create_symlink "$source" "$target"
    else
        log WARN ".vimrc not found in $SCRIPT_DIR"
    fi
}

# ============================================================================
# Main Functions
# ============================================================================

install_configs() {
    local force=${1:-false}
    
    log INFO "Starting configuration installation..."
    log INFO "Script directory: $SCRIPT_DIR"
    log INFO "Force mode: $force"
    
    # Process standard configurations
    for config in "${!CONFIG_ITEMS[@]}"; do
        local source="$SCRIPT_DIR/$config"
        local target="${CONFIG_ITEMS[$config]}"
        
        log INFO "Processing $config..."
        create_symlink "$source" "$target" "$force"
    done
    
    # Process special configurations
    for config in "${!SPECIAL_CONFIGS[@]}"; do
        log INFO "Processing special config: $config..."
        ${SPECIAL_CONFIGS[$config]}
    done
    
    # Install oh-my-zsh if not present
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log INFO "Installing Oh My Zsh..."
        if command_exists curl; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            log SUCCESS "Oh My Zsh installed"
        else
            log ERROR "curl not found. Please install curl to install Oh My Zsh"
        fi
    else
        log INFO "Oh My Zsh already installed"
    fi
    
    log SUCCESS "Configuration installation completed!"
    log INFO "Log file: $LOG_FILE"
}

uninstall_configs() {
    log INFO "Starting configuration removal..."
    
    # Remove standard configurations
    for config in "${!CONFIG_ITEMS[@]}"; do
        local target="${CONFIG_ITEMS[$config]}"
        
        if [[ -L "$target" ]]; then
            rm -f "$target"
            log SUCCESS "Removed symlink: $target"
        else
            log INFO "Not a symlink, skipping: $target"
        fi
    done
    
    # Handle special configurations
    if [[ -L "$HOME/.config/lazygit/config.yml" ]]; then
        rm -f "$HOME/.config/lazygit/config.yml"
        log SUCCESS "Removed lazygit config symlink"
    fi
    
    if [[ -L "$HOME/.tmux.conf" ]]; then
        rm -f "$HOME/.tmux.conf"
        log SUCCESS "Removed .tmux.conf symlink"
    fi
    
    if [[ -L "$HOME/.vimrc" ]]; then
        rm -f "$HOME/.vimrc"
        log SUCCESS "Removed .vimrc symlink"
    fi
    
    log SUCCESS "Configuration removal completed!"
}

show_status() {
    log INFO "Configuration Status Report"
    echo "===================================="
    
    # Check standard configurations
    for config in "${!CONFIG_ITEMS[@]}"; do
        local source="$SCRIPT_DIR/$config"
        local target="${CONFIG_ITEMS[$config]}"
        
        printf "%-15s: " "$config"
        
        if [[ -L "$target" ]]; then
            local link_target=$(readlink -f "$target" 2>/dev/null || echo "unknown")
            if [[ "$link_target" == "$source" ]]; then
                echo -e "${GREEN}✓ Linked${NC}"
            else
                echo -e "${YELLOW}⚠ Linked to different source${NC}"
            fi
        elif [[ -e "$target" ]]; then
            echo -e "${YELLOW}⚠ Exists but not linked${NC}"
        else
            echo -e "${RED}✗ Not configured${NC}"
        fi
    done
    
    # Check special configurations
    echo "------------------------------------"
    echo "Special Configurations:"
    
    for config in "${!SPECIAL_CONFIGS[@]}"; do
        printf "%-15s: " "$config"
        
        case "$config" in
            "lazygit")
                if [[ -L "$HOME/.config/lazygit/config.yml" ]]; then
                    echo -e "${GREEN}✓ Configured${NC}"
                else
                    echo -e "${RED}✗ Not configured${NC}"
                fi
                ;;
            "xprofile")
                if [[ -f "$HOME/.xprofile" ]]; then
                    echo -e "${GREEN}✓ Present${NC}"
                else
                    echo -e "${RED}✗ Not present${NC}"
                fi
                ;;
            "tmux")
                if [[ -e "$HOME/.tmux.conf" ]]; then
                    echo -e "${GREEN}✓ Configured${NC}"
                else
                    echo -e "${RED}✗ Not configured${NC}"
                fi
                ;;
            "vimrc")
                if [[ -e "$HOME/.vimrc" ]]; then
                    echo -e "${GREEN}✓ Configured${NC}"
                else
                    echo -e "${RED}✗ Not configured${NC}"
                fi
                ;;
        esac
    done
    
    echo "===================================="
}

show_help() {
    cat << EOF
Auto Configuration Manager v2.0.0

USAGE:
    $0 [OPTIONS] [COMMAND]

COMMANDS:
    install     Install all configurations (default)
    uninstall   Remove all symlinks
    status      Show current configuration status
    help        Show this help message

OPTIONS:
    -f, --force     Force overwrite existing configurations
    -h, --help      Show this help message

EXAMPLES:
    $0                  # Install configurations (interactive)
    $0 install          # Install configurations
    $0 -f install       # Force install configurations
    $0 uninstall        # Remove all symlinks
    $0 status           # Check configuration status

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
    local force=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force)
                force=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            install|uninstall|status|help)
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
    
    # Execute command
    case "$command" in
        install)
            install_configs "$force"
            ;;
        uninstall)
            read -p "Are you sure you want to uninstall all configurations? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                uninstall_configs
            else
                log INFO "Uninstall cancelled"
            fi
            ;;
        status)
            show_status
            ;;
        help)
            show_help
            ;;
        *)
            log ERROR "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"





