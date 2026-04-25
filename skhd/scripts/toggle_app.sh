#!/usr/bin/env bash
set -euo pipefail

app="${1:?usage: toggle_app.sh APP_NAME [WINDOW_TITLE_HINT]}"
title_hint="${2:-}"

front_app="$(
    osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null || true
)"
front_title="$(
    osascript -e 'tell application "System Events" to tell first application process whose frontmost is true to get name of front window' 2>/dev/null || true
)"

if [[ "$front_app" == "$app" && ( -z "$title_hint" || "$front_title" == *"$title_hint"* ) ]]; then
    osascript -e "tell application \"System Events\" to set visible of application process \"$app\" to false"
    exit 0
fi

if [[ "$app" == "Alacritty" && -n "$title_hint" ]]; then
    window_id="$(
        yabai -m query --windows 2>/dev/null \
            | jq -r --arg app "$app" --arg title "$title_hint" \
                'map(select(.app == $app and (.title | contains($title)))) | first | .id // empty' 2>/dev/null || true
    )"

    if [[ -n "$window_id" ]]; then
        yabai -m window --focus "$window_id"
        exit 0
    fi

    if [[ -z "$window_id" ]]; then
        case "$title_hint" in
            translate)
                open -na Alacritty --args --title translate -e zsh -lc 'trans -shell -t zh -4 -sp'
                ;;
            AItrans)
                open -na Alacritty --args --title AItrans -e zsh -lc '${GOPATH:-$HOME/go}/bin/chatgpt -d -p translator'
                ;;
            *)
                open -na Alacritty --args --title "$title_hint"
                ;;
        esac
    fi
else
    open -a "$app"
fi

osascript -e "tell application \"$app\" to activate"
