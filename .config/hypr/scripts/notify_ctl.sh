#!/bin/bash

# A unified script for volume and brightness notifications with dynamic icons.

# Usage: ./notify_ctl.sh [volume|brightness]



MODE=$1



# Use a case statement to handle different modes

case $MODE in

volume)

# Get volume and mute status

VOLUME=$(pamixer --get-volume)

MUTED=$(pamixer --get-mute)



# Set icon based on status

if [ "$MUTED" = "true" ]; then

ICON="" # Muted

elif [ "$VOLUME" -ge 100 ]; then

ICON="" # Max Volume

else

ICON="󰕾" # Mid Volume

fi



# Send notification

dunstify -i "$ICON" -h string:x-dunst-stack-tag:"Volume" -h int:value:"$VOLUME" -u low --replace=9991 "Volume"

;;



brightness)

# Get brightness percentage

BRIGHTNESS=$(brightnessctl -m | awk -F, '{print substr($4, 0, length($4)-1)}')



# Set icon based on level

if [ "$BRIGHTNESS" -gt 66 ]; then

ICON="󰃠" # High Brightness

elif [ "$BRIGHTNESS" -gt 33 ]; then

ICON="󰃟" # Mid Brightness

else

ICON="󰃞" # Low Brightness

fi



# Send notification

dunstify -i "$ICON" -h string:x-dunst-stack-tag:"Brightness" -h int:value:"$BRIGHTNESS" -u low --replace=9991 "Brightness"

;;

esac