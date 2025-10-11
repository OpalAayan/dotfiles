#!/bin/bash

# This script toggles wlsunset and adjusts its temperature,
# handling the max temperature as a special "off" state.

# --- CONFIGURATION ---
DEFAULT_TEMP=4500   # The temperature to use when turning on for the first time
STEP=100            # How much to increase/decrease the temperature by
MIN_TEMP=2500       # The warmest temperature allowed
MAX_TEMP=6500       # The coolest temperature allowed (daylight)
# --- END CONFIGURATION ---

STATE_FILE="/tmp/wlsunset_current_temp.dat"
DAYLIGHT_TEMP_THRESHOLD=6499 # Just below MAX_TEMP

# Function to safely get the current temperature from the state file
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

# Function to turn off wlsunset completely
turn_off_wlsunset() {
    killall wlsunset 2>/dev/null
    notify-send -i "weather-clear" -h string:synchronous:wlsunset-temp "Night Light" "Turned OFF (Daylight)"
}

# Function to apply a new temperature
apply_temp() {
    local temp=$1
    # Ensure wlsunset is not running before starting a new instance
    killall wlsunset 2>/dev/null
    
    # Run the new wlsunset instance
    wlsunset -t "$temp" &
    
    # Save the new temperature to the state file
    echo "$temp" > "$STATE_FILE"

    # Calculate percentage for notification bar (0-100)
    PERCENT=$(( ( (temp - MIN_TEMP) * 100) / (MAX_TEMP - MIN_TEMP) ))
    notify-send -i "weather-clear" -h int:value:"$PERCENT" -h string:synchronous:wlsunset-temp "Night Light" "Temperature: ${temp}K"
}


case "$1" in
    increase)
        if pgrep -x "wlsunset" > /dev/null; then
            current_temp=$(get_current_temp)
            new_temp=$((current_temp + STEP))

            # --- ROBUST LOGIC BLOCK ---
            if [ "$new_temp" -ge "$MAX_TEMP" ]; then
                # If we hit or exceed the max temp, just turn it off.
                turn_off_wlsunset
            else
                # Otherwise, apply the new temp.
                apply_temp "$new_temp"
            fi
        fi
        ;;

    decrease)
        current_temp=$(get_current_temp)
        
        if pgrep -x "wlsunset" > /dev/null; then
            # If it's already running, decrease from its current temp
            new_temp=$((current_temp - STEP))
            if [ "$new_temp" -lt "$MIN_TEMP" ]; then
                new_temp=$MIN_TEMP
            fi
            apply_temp "$new_temp"
        else
            # If it's OFF, decreasing should turn it ON,
            # but not at full daylight. Start from just below max.
            apply_temp "$DAYLIGHT_TEMP_THRESHOLD"
        fi
        ;;

    *)
        # Default action: Toggle
        if pgrep -x "wlsunset" > /dev/null; then
            turn_off_wlsunset
        else
            initial_temp=$(get_current_temp)
            # Prevent toggling on directly to the "off" state
            if [ "$initial_temp" -ge "$MAX_TEMP" ]; then
                initial_temp=$DEFAULT_TEMP
            fi
            apply_temp "$initial_temp"
        fi
        ;;
esac