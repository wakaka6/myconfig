#!/usr/bin/env bash

# inspired by https://github.com/guimeira/i3lock-fancy-multimonitor

#Constants
DISPLAY_RE="([0-9]+)x([0-9]+)\\+([0-9]+)\\+([0-9]+)" # Regex to find display dimensions
PARAMS="-colorspace sRGB" # ensure that images are created in sRGB colorspace, to avoid greyscale output
DEFAULT_CACHE_FOLDER="$HOME"/.cache/i3lock-img/ # Cache folder
UUID="d064e7de-2d7a-449a-b538-aeb40659bf11" # Unique ID for the lock image, generated with uuidgen
UNIQUE_PREFIX="i3lock-image-${UUID}-"

CACHE_FOLDER=$DEFAULT_CACHE_FOLDER

if [[ $CACHE_FOLDER != */ ]]; then
    CACHE_FOLDER="$CACHE_FOLDER/"
fi

# Create the cache folder if it does not exist
if ! [ -e $CACHE_FOLDER ]; then
    mkdir -p $CACHE_FOLDER
fi

#Image paths
BKG_IMG=$HOME/myconfig/i3/lock.png  # change this

LOCK_IMG=$(basename "$BKG_IMG")

OUTPUT_IMG_WIDTH=0 # Decide size to cover all screens
OUTPUT_IMG_HEIGHT=0 # Decide size to cover all screens

# Store display metadata for later reuse when composing and calculating canvas
declare -a SCREENS=()
MIN_X=0
MIN_Y=0
MAX_X=0
MAX_Y=0
FIRST_SCREEN=1
while read -r LINE
do
  if [[ $LINE =~ $DISPLAY_RE ]]; then
    SCREEN_WIDTH=${BASH_REMATCH[1]}
    SCREEN_HEIGHT=${BASH_REMATCH[2]}
    SCREEN_X=${BASH_REMATCH[3]}
    SCREEN_Y=${BASH_REMATCH[4]}

    SCREENS+=("${SCREEN_WIDTH}:${SCREEN_HEIGHT}:${SCREEN_X}:${SCREEN_Y}")

    if (( FIRST_SCREEN )); then
        MIN_X=$SCREEN_X
        MIN_Y=$SCREEN_Y
        MAX_X=$((SCREEN_X + SCREEN_WIDTH))
        MAX_Y=$((SCREEN_Y + SCREEN_HEIGHT))
        FIRST_SCREEN=0
    else
        if (( SCREEN_X < MIN_X )); then MIN_X=$SCREEN_X; fi
        if (( SCREEN_Y < MIN_Y )); then MIN_Y=$SCREEN_Y; fi
        if (( SCREEN_X + SCREEN_WIDTH > MAX_X )); then MAX_X=$((SCREEN_X + SCREEN_WIDTH)); fi
        if (( SCREEN_Y + SCREEN_HEIGHT > MAX_Y )); then MAX_Y=$((SCREEN_Y + SCREEN_HEIGHT)); fi
    fi
  fi
done < <(xrandr)

if (( ${#SCREENS[@]} == 0 )); then
    echo "No connected displays detected. Aborting lock to avoid wrong image." >&2
    exit 1
fi

OUTPUT_IMG_WIDTH=$((MAX_X - MIN_X))
OUTPUT_IMG_HEIGHT=$((MAX_Y - MIN_Y))
OUTPUT_IMG="$CACHE_FOLDER""$UNIQUE_PREFIX""${OUTPUT_IMG_WIDTH}x${OUTPUT_IMG_HEIGHT}-""$LOCK_IMG"

DEFAULT_LOCK_CMD="i3lock -e -f -n -i $OUTPUT_IMG"
LOCK_CMD="${LOCK_CMD_OVERRIDE:-$DEFAULT_LOCK_CMD}"

function lock_screen() {
    # Terminate already running picom instances
    killall -q picom

    # suspend message display
    pkill -u "$USER" -USR1 dunst
    # Wait until the processes have been shut down
    while pgrep -u $UID -x picom >/dev/null; do sleep 0.1; done

    # the lock screen
    # i3lock -n -c 000000
    $LOCK_CMD

    # resume message display
    pkill -u "$USER" -USR2 dunst
    # restart picom
    picom -b --inactive-dim 0.02
}

if [ -e "$OUTPUT_IMG" ]
then
    # Lock screen since image already exists for current layout
    lock_screen
    exit 0
fi

PARAMS="-colorspace sRGB"

for SCREEN in "${SCREENS[@]}"
do
  IFS=: read -r SCREEN_WIDTH SCREEN_HEIGHT SCREEN_X SCREEN_Y <<< "$SCREEN"

  CACHE_IMG="${CACHE_FOLDER}${UNIQUE_PREFIX}${SCREEN_WIDTH}x${SCREEN_HEIGHT}-${LOCK_IMG}"
  if ! [ -e "$CACHE_IMG" ]
  then
      # Create image for that screensize
      eval magick '$BKG_IMG' '-resize' '${SCREEN_WIDTH}X${SCREEN_HEIGHT}^' '-gravity' 'Center' '-crop' '${SCREEN_WIDTH}X${SCREEN_HEIGHT}+0+0' '+repage' '$CACHE_IMG'
  fi

  REL_X=$((SCREEN_X - MIN_X))
  REL_Y=$((SCREEN_Y - MIN_Y))

  PARAMS="$PARAMS -type TrueColor $CACHE_IMG -geometry +${REL_X}+${REL_Y} -composite "
done

#Execute ImageMagick:
eval magick -size ${OUTPUT_IMG_WIDTH}x${OUTPUT_IMG_HEIGHT} 'xc:black' '$OUTPUT_IMG'
eval magick '$OUTPUT_IMG' $PARAMS '$OUTPUT_IMG'

#Lock the screen:
lock_screen
