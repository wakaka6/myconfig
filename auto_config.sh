#!/usr/bin/env bash
# Compatibility wrapper. The zsh installer is the maintained implementation and
# works on both macOS and Linux.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v zsh >/dev/null 2>&1; then
    echo "zsh is required to run this installer. Install zsh, then run:" >&2
    echo "  $script_dir/auto_config.zsh $*" >&2
    exit 1
fi

exec zsh "$script_dir/auto_config.zsh" "$@"
