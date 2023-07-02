#!/usr/bin/env sh

# Terminate already running picom instances
killall -q picom

# Wait until the processes have been shut down
while pgrep -u $UID -x picom >/dev/null; do sleep 0.1; done

# the lock screen
# i3lock -n -c 000000
i3lock -n -i $HOME/myconfig/i3/lock.png

# Wait until screen unlock
# while pgrep -u $UID -x i3lock >/dev/null; do sleep 1; done

# restart picom
picom -b --inactive-dim 0.02
