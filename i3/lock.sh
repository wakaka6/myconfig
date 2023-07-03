#!/usr/bin/env bash

# inspired by https://github.com/guimeira/i3lock-fancy-multimonitor

#Constants
DISPLAY_RE="([0-9]+)x([0-9]+)\\+([0-9]+)\\+([0-9]+)" # Regex to find display dimensions
PARAMS="-colorspace sRGB" # ensure that images are created in sRGB colorspace, to avoid greyscale output
DEFAULT_CACHE_FOLDER="$HOME"/.cache/i3lock-img/ # Cache folder
UUID="d064e7de-2d7a-449a-b538-aeb40659bf11" # Unique ID for the lock image, generated with uuidgen
UNIQUE_PREFIX="i3lock-image-${UUID}-"

CACHE_FOLDER=$DEFAULT_CACHE_FOLDER

if ! [[ "$CACHE_FOLDER" == "*/" ]]; then
    CACHE_FOLDER="$CACHE_FOLDER/"
fi

# Create the cache folder if it does not exist
if ! [ -e $CACHE_FOLDER ]; then
    mkdir -p $CACHE_FOLDER
fi

#Image paths
BKG_IMG=$HOME/myconfig/i3/lock.png  # change this

LOCK_IMG=$(basename "$BKG_IMG")

OUTPUT_IMG="$CACHE_FOLDER""$UNIQUE_PREFIX""$LOCK_IMG" # Path of final image
OUTPUT_IMG_WIDTH=0 # Decide size to cover all screens
OUTPUT_IMG_HEIGHT=0 # Decide size to cover all screens


LOCK_CMD="i3lock -e -f -n -i $OUTPUT_IMG"

function lock_screen() {
    # Terminate already running picom instances
    killall -q picom

    # Wait until the processes have been shut down
    while pgrep -u $UID -x picom >/dev/null; do sleep 0.1; done

    # the lock screen
    # i3lock -n -c 000000
    $LOCK_CMD

    # Wait until screen unlock
    # while pgrep -u $UID -x i3lock >/dev/null; do sleep 1; done

    # restart picom
    picom -b --inactive-dim 0.02
}



if [ -e $OUTPUT_IMG ]
then
    # Lock screen since image already exists
    lock_screen
    exit 0
fi

#Execute xrandr to get information about the monitors:
while read LINE
do
  #If we are reading the line that contains the position information:
  if [[ $LINE =~ $DISPLAY_RE ]]; then
    #Extract information and append some parameters to the ones that will be given to ImageMagick:
    SCREEN_WIDTH=${BASH_REMATCH[1]}
    SCREEN_HEIGHT=${BASH_REMATCH[2]}
    SCREEN_X=${BASH_REMATCH[3]}
    SCREEN_Y=${BASH_REMATCH[4]}

    CACHE_IMG="${CACHE_FOLDER}${UNIQUE_PREFIX}${SCREEN_WIDTH}x${SCREEN_HEIGHT}-${LOCK_IMG}"
    echo $CACHE_IMG
    ## if cache for that screensize doesnt exist
    if ! [ -e $CACHE_IMG ]
    then
	# Create image for that screensize
        eval convert '$BKG_IMG' '-resize' '${SCREEN_WIDTH}X${SCREEN_HEIGHT}^' '-gravity' 'Center' '-crop' '${SCREEN_WIDTH}X${SCREEN_HEIGHT}+0+0' '+repage' '$CACHE_IMG'
    fi

    # Decide size of output image
    if (( $OUTPUT_IMG_WIDTH < $SCREEN_WIDTH+$SCREEN_X )); then OUTPUT_IMG_WIDTH=$(($SCREEN_WIDTH+$SCREEN_X)); fi;
    if (( $OUTPUT_IMG_HEIGHT < $SCREEN_HEIGHT+$SCREEN_Y )); then OUTPUT_IMG_HEIGHT=$(( $SCREEN_HEIGHT+$SCREEN_Y )); fi;

    PARAMS="$PARAMS -type TrueColor $CACHE_IMG -geometry +$SCREEN_X+$SCREEN_Y -composite "
  fi
done <<<"`xrandr`"

#Execute ImageMagick:
eval convert -size ${OUTPUT_IMG_WIDTH}x${OUTPUT_IMG_HEIGHT} 'xc:black' $OUTPUT_IMG
eval convert $OUTPUT_IMG $PARAMS $OUTPUT_IMG

#Lock the screen:
lock_screen
