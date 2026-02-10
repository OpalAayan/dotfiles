#!/bin/bash
# Waybar helper for nightlight status

MIN_TEMP=2500
MAX_TEMP=6500

# Get current temperature
temp=$(busctl --user get-property rs.wl-gammarelay / rs.wl.gammarelay Temperature 2>/dev/null | awk '{print $2}')

# Default to max if query fails
if [[ ! "$temp" =~ ^[0-9]+$ ]]; then
    temp=$MAX_TEMP
fi

# Determine icon and class based on temperature
if [ "$temp" -ge "$MAX_TEMP" ]; then
    icon="󰖙"  # Sun - Off state
    class="off"
    tooltip="Night Light: Off"
elif [ "$temp" -ge 5000 ]; then
    icon="󰖙"  # Sun
    class="cool"
    tooltip="Night Light: ${temp}K (Cool)"
elif [ "$temp" -ge 4000 ]; then
    icon="󰖨"  # Sunset
    class="warm"
    tooltip="Night Light: ${temp}K (Warm)"
else
    icon="󰖔"  # Moon
    class="hot"
    tooltip="Night Light: ${temp}K (Hot)"
fi

# Output JSON for waybar
echo "{\"text\": \"$icon\", \"tooltip\": \"$tooltip\", \"class\": \"$class\", \"alt\": \"$class\"}"
