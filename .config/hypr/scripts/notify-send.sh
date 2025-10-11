#!/bin/bash
# A script to send notifications that are compatible with dunstrc progress_bar rules,
# now with dynamic icons for Volume and Brightness.

# The first argument ($1) is now a fallback, the script determines the primary icon.
FALLBACK_ICON="$1"
TITLE="$2"
VALUE="$3"

# This variable will hold the final icon path or name
ICON=""

# Check the TITLE to decide which icon logic to apply
if [ "$TITLE" = "Volume" ]; then
    # Check mute status first, as it overrides volume level
    if [ "$(pamixer --get-mute)" = "true" ]; then
        ICON="" # Muted
    elif [ "$VALUE" -ge 100 ]; then
        ICON="" # Max Volume
    else
        ICON="󰕾" # Mid Volume
    fi
elif [ "$TITLE" = "Brightness" ]; then
    if [ "$VALUE" -gt 66 ]; then
        ICON="󰃠" # High Brightness
    elif [ "$VALUE" -gt 33 ]; then
        ICON="󰟟" # Mid Brightness
    else
        ICON="󰃞" # Low Brightness
    fi
else
    # If the title is not recognized, use the original icon passed as an argument
    ICON="$FALLBACK_ICON"
fi

# Send the notification using the determined icon
dunstify \
    -i "$ICON" \
    -h string:x-dunst-stack-tag:"$TITLE" \
    -h int:value:"$VALUE" \
    -u low \
    --replace=9991 \
    "$TITLE"



