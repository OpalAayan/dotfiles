#!/usr/bin/env bash
# Usage: ./smart_resize.sh <direction> <step_size>
# Example: ./smart_resize.sh l 20

direction=$1
step=${2:-20} # Default step size is 20px

# Get Active Window Info
active_window=$(hyprctl activewindow -j)
box_x=$(echo "$active_window" | jq '.at[0]')
box_y=$(echo "$active_window" | jq '.at[1]')
box_w=$(echo "$active_window" | jq '.size[0]')
box_h=$(echo "$active_window" | jq '.size[1]')

# Get Active Monitor Info (to calculate edges)
# We select the monitor where the focused window is located
monitor=$(hyprctl monitors -j | jq '.[] | select(.focused == true)')
mon_x=$(echo "$monitor" | jq '.x')
mon_y=$(echo "$monitor" | jq '.y')
mon_w=$(echo "$monitor" | jq '.width')
mon_h=$(echo "$monitor" | jq '.height')

# Calculate Window and Monitor Edges
# Right and Bottom coordinates
win_r=$((box_x + box_w))
win_b=$((box_y + box_h))
mon_r=$((mon_x + mon_w))
mon_b=$((mon_y + mon_h))

# Threshold for edge detection (pixels)
# Useful if you have gaps or borders
gap=20

case $direction in
l | left)
  # LEFT KEY
  # If we are touching the LEFT edge of the monitor: Shrink (pull right border left)
  if [ $((box_x - gap)) -le $mon_x ]; then
    hyprctl dispatch resizeactive -$step 0
  else
    # Otherwise: Grow (push left border left)
    hyprctl dispatch resizeactive $step 0
  fi
  ;;
r | right)
  # RIGHT KEY
  # If we are touching the RIGHT edge: Shrink (pull left border right)
  if [ $((win_r + gap)) -ge $mon_r ]; then
    hyprctl dispatch resizeactive -$step 0
  else
    # Otherwise: Grow (push right border right)
    hyprctl dispatch resizeactive $step 0
  fi
  ;;
u | up)
  # UP KEY
  # If we are touching the TOP edge: Shrink (pull bottom border up)
  if [ $((box_y - gap)) -le $mon_y ]; then
    hyprctl dispatch resizeactive 0 -$step
  else
    # Otherwise: Grow (push top border up)
    hyprctl dispatch resizeactive 0 $step
  fi
  ;;
d | down)
  # DOWN KEY
  # If we are touching the BOTTOM edge: Shrink (pull top border down)
  if [ $((win_b + gap)) -ge $mon_b ]; then
    hyprctl dispatch resizeactive 0 -$step
  else
    # Otherwise: Grow (push bottom border down)
    hyprctl dispatch resizeactive 0 $step
  fi
  ;;
esac
