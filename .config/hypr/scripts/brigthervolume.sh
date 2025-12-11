#!/bin/bash

# Usage: ./brigthervolume.sh [up|down|mute|brightness_up|brightness_down]

action=$1
# Custom appname to target in dunstrc (Fixes watermark later)
APPNAME="volume_overlay"
# Notification ID to replace (prevents stack lag)
NOTIF_ID=9991

# --- Volume Function (Now 3% step) ---
handle_volume() {
    case $1 in
        up)   wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 3%+ ;;
        down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%- ;;
        mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    esac

    # Get Status
    status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    
    # Parse Volume (0.03 -> 3)
    vol_float=$(echo "$status" | awk '{print $2}')
    vol=$(echo "$vol_float * 100" | bc | awk '{print int($1)}')
    
    # Parse Mute & Icons
    if [[ "$status" == *"[MUTED]"* ]]; then
        icon=""
        text="Muted"
    else
        if [ "$vol" -gt 100 ]; then icon="";
        elif [ "$vol" -eq 100 ]; then icon="";
        elif [ "$vol" -ge 60 ]; then icon="󱑽";
        elif [ "$vol" -ge 42 ]; then icon="";
        elif [ "$vol" -ge 1 ]; then icon="";
        else icon=""; fi
        text="$vol%"
    fi

    # Send Notification
    dunstify -a "$APPNAME" -u low -r "$NOTIF_ID" \
             -h int:value:"$vol" \
             -h string:x-dunst-stack-tag:"volume" \
             "$icon $text"
             
    # Play sound only if unmuting
    if [ "$1" == "mute" ] && [[ "$status" != *"[MUTED]"* ]]; then
        paplay /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga &
    fi
}

# --- Brightness Function ---
handle_brightness() {
    # 1. Change Brightness
    case $1 in
        up)   brightnessctl set 5%+ ;;
        down) brightnessctl set 5%- ;;
    esac

    # 2. Get Current Brightness % (Clean parsing)
    bright=$(brightnessctl -m | awk -F, '{print substr($4, 0, length($4)-1)}')

    # 3. Set Icon
    if [ "$bright" -gt 66 ]; then icon="󰃠";
    elif [ "$bright" -gt 33 ]; then icon="󰃟";
    else icon="󰃞"; fi

    # 4. Notify
    dunstify -a "$APPNAME" -u low -r "$NOTIF_ID" \
             -h int:value:"$bright" \
             -h string:x-dunst-stack-tag:"brightness" \
             "$icon $bright%"
}

# --- Main Switch ---
case $action in
    up|down|mute) handle_volume "$action" ;;
    brightness_up) handle_brightness "up" ;;
    brightness_down) handle_brightness "down" ;;
esac