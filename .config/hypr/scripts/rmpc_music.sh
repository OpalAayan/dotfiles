#!/bin/bash

# 1. Start MPD if it's not running
if ! pgrep -x "mpd" > /dev/null; then
    echo "Starting MPD..."
    mpd
    
    # Wait for MPD to be ready (Loop for 5 seconds)
    for i in {1..5}; do
        # Check if port 6600 is open
        if echo "close" | nc 127.0.0.1 6600 >/dev/null 2>&1; then
            break
        fi
        echo "Waiting for MPD socket..."
        sleep 0.5
    done
else
    echo "MPD is already running."
fi

# 2. Launch the client (Script pauses here until you close rmpc)
rmpc

# 3. Cleanup: Kill MPD immediately after rmpc closes
echo "Stopping MPD..."
pkill -x mpd