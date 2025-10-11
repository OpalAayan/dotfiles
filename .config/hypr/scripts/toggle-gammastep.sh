#!/bin/bash

# Your notification script path
NOTIFY_SCRIPT="$HOME/.config/hypr/scripts/notify-send.sh"

# Your latitude and longitude
LAT="28.6"
LON="77.2"

if pgrep -x "gammastep" > /dev/null
then
    # If gammastep is running, kill it and send a notification
    pkill gammastep
    $NOTIFY_SCRIPT "weather-clear" "Night Light" "OFF"
else
    # If gammastep is not running, start it in the background and send a notification
    gammastep -l "$LAT:$LON" &
    $NOTIFY_SCRIPT "weather-clear-night" "Night Light" "ON"
fi