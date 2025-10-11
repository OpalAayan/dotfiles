#!/bin/bash
#
# ██╗    ██╗ █████╗ ██╗     ██╗     ███████╗███████╗███████╗
# ██║    ██║██╔══██╗██║     ██║     ██╔════╝██╔════╝██╔════╝
# ██║ █╗ ██║███████║██║     ██║     █████╗  █████╗  █████╗
# ██║███╗██║██╔══██║██║     ██║     ██╔══╝  ██╔══╝  ██╔══╝
# ╚███╔███╔╝██║  ██║███████╗███████╗███████╗██║     ███████╗
#  ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝     ╚══════╝
#
#           Wallpaper Changer - Sequential & Cool
#

# --- CONFIGURATION ---
WALLPAPER_DIR="$HOME/Pictures/HyprWalls"
STATE_FILE="$HOME/.cache/wallpaper_index.txt"

# --- COOL TRANSITION SETTINGS ---
# 'any' provides the random "from anywhere" effect you liked.
TRANSITION_TYPE="any"
TRANSITION_FPS=144
TRANSITION_DURATION=2

# --- SCRIPT LOGIC ---

# Define some colors for stylish terminal output
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_NC='\033[0m' # No Color

# Ensure the cache directory exists
mkdir -p "$(dirname "$STATE_FILE")"

# Get a sorted list of all wallpapers
mapfile -d '' WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 | sort -z)

# Exit if no wallpapers are found
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send -u critical "Wallpaper Script Error" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Read the last used index. Default to -1 if the file doesn't exist.
LAST_INDEX=-1
if [ -f "$STATE_FILE" ]; then
    LAST_INDEX=$(cat "$STATE_FILE")
fi

# Calculate the next index, looping back to the start if necessary.
if ! [[ "$LAST_INDEX" =~ ^[0-9]+$ ]] || [ "$LAST_INDEX" -ge "${#WALLPAPERS[@]}" ]; then
    LAST_INDEX=-1
fi
NEXT_INDEX=$(( (LAST_INDEX + 1) % ${#WALLPAPERS[@]} ))

# Select the wallpaper for the new index
NEXT_WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"
WALLPAPER_BASENAME=$(basename "$NEXT_WALLPAPER")

# Set the wallpaper using your preferred random, high-framerate settings
swww img "$NEXT_WALLPAPER" \
    --transition-type "$TRANSITION_TYPE" \
    --transition-fps "$TRANSITION_FPS" \
    --transition-duration "$TRANSITION_DURATION"

# Save the new index to the state file for the next run
echo "$NEXT_INDEX" > "$STATE_FILE"

# Send a notification with a thumbnail of the new wallpaper
notify-send -i "$NEXT_WALLPAPER" "Wallpaper Changed" "$WALLPAPER_BASENAME"

# Echo to terminal with some style
echo -e "${C_GREEN}Wallpaper set to:${C_NC} ${C_BLUE}$WALLPAPER_BASENAME${C_NC}"