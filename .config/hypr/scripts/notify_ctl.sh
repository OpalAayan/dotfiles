#!/bin/bash
# A unified script for volume and brightness notifications with dynamic icons.
# Now with a 'volume_mute' mode that plays a sound on unmute.

# Usage: ./notify_ctl.sh [volume|volume_mute|brightness]

MODE=$1

# --- CONFIG ---
# This is a standard system sound, should work on most distros
UNMUTE_SOUND="/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"
# --- END CONFIG ---


# --- Function to get volume status and send notification ---
# We create this function so 'volume' and 'volume_mute' can both use it.
get_volume_notification() {
    # Get volume and mute status
    VOLUME=$(pamixer --get-volume)
    MUTED=$(pamixer --get-mute)

    # --- START of NEW DYNAMIC ICON LOGIC ---
    # Set icon based on status, checking in order of precedence
    if [ "$MUTED" = "true" ]; then
        ICON="" # Muted
    elif [ "$VOLUME" -gt 100 ]; then
        ICON="" # Over-amplified (100%+)
    elif [ "$VOLUME" -eq 100 ]; then
        ICON="" # 100%
    elif [ "$VOLUME" -ge 50 ]; then
        ICON="󱑽" # 50% - 99%
    elif [ "$VOLUME" -ge 1 ]; then
        ICON="" # 1% - 49%
    else
        ICON="" # 0% (but not muted)
    fi
    # --- END of NEW DYNAMIC ICON LOGIC ---

    # Send notification (with the icon in the text, as we fixed)
    dunstify -h string:x-dunst-stack-tag:"Volume" -h int:value:"$VOLUME" -u low --replace=9991 "$ICON Volume"
}
# --- End of Function ---


# Use a case statement to handle different modes
case $MODE in

volume)
    # Called by Volume Up/Down (binde)
    # No sound, just the notification
    get_volume_notification
    ;;

volume_mute)
    # Called by Mute key (bind)
    
    # 1. Toggle the mute
    pamixer -t
    
    # 2. Show the new notification
    get_volume_notification
    
    # 3. Check if we just UNMUTED, and play sound
    if [ "$(pamixer --get-mute)" = "false" ]; then
        # Play sound in the background (&) so it doesn't block the script
        # We also redirect output to /dev/null to prevent any 'paplay' spam
        paplay "$UNMUTE_SOUND" &> /dev/null &
    fi
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

    # Send notification (with the icon in the text, as we fixed)
    dunstify -h string:x-dunst-stack-tag:"Brightness" -h int:value:"$BRIGHTNESS" -u low --replace=9991 "$ICON Brightness"
    ;;

esac