#!/bin/bash
#
# ████████╗ ██████╗  ██████╗  ██████╗  ██╗     ███████╗
# ╚══██╔══╝██╔═══██╗██╔════╝ ██╔════╝  ██║     ██╔════╝
#    ██║   ██║   ██║██║  ███╗██║  ███ ╗██║     █████╗
#    ██║   ██║   ██║██║   ██║██║   ██║ ██║     ██╔══╝
#    ██║   ╚██████╔╝╚██████╔╝╚██████╔╝ ███████╗███████╗
#    ╚═╝    ╚═════╝  ╚═════╝  ╚═════╝  ╚══════╝╚══════╝
#
#    Wallpaper Toggle - "The Router"
#
# This script checks if a live wallpaper is active.
# - If YES, it runs the STATIC wallpaper script.
# - If NO, it runs the LIVE wallpaper script.
#

# --- CONFIGURATION ---
# Paths to your two existing scripts
STATIC_SCRIPT="$HOME/.config/hypr/scripts/wallpaper.sh"
LIVE_SCRIPT="$HOME/.config/hypr/scripts/livewallpaper.sh"

# --- TOGGLE LOGIC ---
if pgrep -x "mpvpaper" > /dev/null; then
    # mpvpaper IS running, so we want to switch to STATIC.
    # We call wallpaper.sh, which will kill mpvpaper and start swww.
    echo "Switching to static wallpaper..."
    $STATIC_SCRIPT
else
    # mpvpaper is NOT running, so we want to switch to LIVE.
    # We call livewallpaper.sh, which will kill swww and start mpvpaper.
    echo "Switching to live wallpaper..."
    $LIVE_SCRIPT
fi