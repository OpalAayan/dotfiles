#!/bin/bash

# --- CONFIGURATION ---
DEFAULT_TEMP=4500
STEP=100
MIN_TEMP=2500
MAX_TEMP=6500
# --- END CONFIGURATION ---

STATE_FILE="/tmp/wlsunset_current_temp.dat"
# Appname for Dunst to target (Fixes watermark)
APPNAME="nightlight_overlay"
# Unique ID to prevent it flickering with volume
NOTIF_ID=9992

get_current_temp() {
    if [ -f "$STATE_FILE" ]; then
        local temp_from_file
        temp_from_file=$(cat "$STATE_FILE")
        if [[ "$temp_from_file" =~ ^[0-9]+$ ]]; then
            echo "$temp_from_file"
        else
            echo "$DEFAULT_TEMP"
        fi
    else
        echo "$DEFAULT_TEMP"
    fi
}

turn_off_wlsunset() {
    killall wlsunset 2>/dev/null
    echo "$MAX_TEMP" > "$STATE_FILE"
    #while pgrep -x wlsunset >/dev/null; do sleep 0.01; done

    # Notify Off
    dunstify -a "$APPNAME" -u low -r "$NOTIF_ID" \
             -h int:value:0 \
             -h string:x-dunst-stack-tag:"nightlight" \
             "󰖙 Off"
}

apply_temp() {
    local temp=$1
    killall wlsunset 2>/dev/null
    wlsunset -t "$temp" &
    echo "$temp" > "$STATE_FILE"

    # Calculate Percentage for the bar
    PERCENT=$(( ( (temp - MIN_TEMP) * 100) / (MAX_TEMP - MIN_TEMP) ))

    # Dynamic Icons
    if [ "$temp" -ge 5000 ]; then
        icon="󰖙" # Day / Sun
    elif [ "$temp" -ge 4000 ]; then
        icon="" # Sunset
    else
        icon="󰖔" # Night / Moon
    fi

    # Notify
    dunstify -a "$APPNAME" -u low -r "$NOTIF_ID" \
             -h int:value:"$PERCENT" \
             -h string:x-dunst-stack-tag:"nightlight" \
             "$icon ${temp}K"
}

case "$1" in
    increase)
        if pgrep -x "wlsunset" > /dev/null; then
            current_temp=$(get_current_temp)
            new_temp=$((current_temp + STEP))
            if [ "$new_temp" -ge "$MAX_TEMP" ]; then
                turn_off_wlsunset
            else
                apply_temp "$new_temp"
            fi
        fi
        ;;
    decrease)
        current_temp=$(get_current_temp)
        if pgrep -x "wlsunset" > /dev/null; then
            new_temp=$((current_temp - STEP))
            if [ "$new_temp" -lt "$MIN_TEMP" ]; then new_temp=$MIN_TEMP; fi
            apply_temp "$new_temp"
        else
            # Start just below max if turning on
            apply_temp 6400
        fi
        ;;
    *)
        # Toggle
        if pgrep -x "wlsunset" > /dev/null; then
            turn_off_wlsunset
        else
            initial_temp=$(get_current_temp)
            if [ "$initial_temp" -ge "$MAX_TEMP" ]; then initial_temp=$DEFAULT_TEMP; fi
            apply_temp "$initial_temp"
        fi
        ;;
esac