#!/bin/sh
# Run `kitten hints` only when the screen actually contains a match.
# kitty shows a blocking "No matches found" error overlay when hints finds
# nothing; pre-checking with `kitty @ get-text` avoids it.
#
# Usage: hints-if-match.sh <ere-pattern> [extra hints args...]
# The pattern is a *superset* check (ERE): it must match whenever hints would,
# false positives are fine (they just open the hints UI).
#
# Runs via `map ... remote_control_script`, which gives this script a private
# remote-control fd (KITTY_LISTEN_ON) without enabling allow_remote_control.

KITTY=/opt/homebrew/bin/kitty
pattern=$1
shift

if "$KITTY" @ get-text --extent screen 2>/dev/null | grep -Eq "$pattern"; then
    exec "$KITTY" @ kitten hints "$@"
fi
exit 0
