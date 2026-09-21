#!/bin/sh
# Run `kitten hints` only when the screen actually contains a match.
# kitty shows a blocking "No matches found" error overlay when hints finds
# nothing; pre-checking with `kitty @ get-text` avoids it.
#
# Usage: hints-if-match.sh <pattern> [extra hints args...]
# The pattern is matched with perl (regexp2-compatible: lookarounds and \d
# work). For --type=regex bindings pass the same pattern as --regex so the
# pre-check can never diverge from what hints will match.
#
# Runs via `map ... remote_control_script`, which gives this script a private
# remote-control fd (KITTY_LISTEN_ON) without enabling allow_remote_control.

KITTY=/opt/homebrew/bin/kitty
export HINTS_PATTERN=$1
shift

if "$KITTY" @ get-text --extent screen 2>/dev/null | perl -0777 -ne 'exit(m/$ENV{HINTS_PATTERN}/ ? 0 : 1)'; then
    exec "$KITTY" @ kitten hints "$@"
fi
exit 0
