#!/usr/bin/env bash
set -euo pipefail

front_app="$(
    osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'
)"

if [[ -z "$front_app" ]]; then
    exit 1
fi

osascript <<APPLESCRIPT || osascript -e 'tell application "System Events" to keystroke "w" using command down'
set appName to "$front_app"
try
    tell application appName to close front window
on error
    tell application "System Events" to keystroke "w" using command down
end try
APPLESCRIPT
