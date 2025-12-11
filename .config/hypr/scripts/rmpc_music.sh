#!/bin/bash

# 1. Check if MPD is running
if pgrep -x "mpd" >/dev/null; then
  echo "MPD is already running."
  MPD_WAS_RUNNING=1
else
  echo "Starting MPD..."
  mpd
  MPD_WAS_RUNNING=0
fi

# 2. Launch the client
rmpc

# 3. Cleanup logic
if [ $MPD_WAS_RUNNING -eq 0 ]; then
  echo "Stopping MPD (since we started it)..."
  mpd --kill
else
  echo "Leaving MPD running (since it was already on)."
fi

