#!/usr/bin/env bash
# Usage: ./smart_split.sh k (Horizontal) OR ./smart_split.sh j (Vertical)

direction=$1

# Function to check current coordinates
get_coords() {
  hyprctl activewindow -j | jq -r '.at[0],.at[1]' | tr '\n' ' '
}

start_coords=$(get_coords)

if [[ "$direction" == "k" ]]; then
  # === K KEY: HORIZONTAL SHUFFLE ===
  # 1. Try move RIGHT
  hyprctl dispatch movewindow r
  check1=$(get_coords)

  if [[ "$start_coords" == "$check1" ]]; then
    # Right failed (we are at edge). Try move LEFT to cycle back.
    hyprctl dispatch movewindow l
    check2=$(get_coords)

    # If Left ALSO failed, we have no horizontal neighbors.
    # Force layout change to Horizontal.
    if [[ "$start_coords" == "$check2" ]]; then
      hyprctl dispatch togglesplit
    fi
  fi

elif [[ "$direction" == "j" ]]; then
  # === J KEY: VERTICAL SHUFFLE ===
  # 1. Try move DOWN
  hyprctl dispatch movewindow d
  check1=$(get_coords)

  if [[ "$start_coords" == "$check1" ]]; then
    # Down failed (we are at bottom). Try move UP to cycle back.
    hyprctl dispatch movewindow u
    check2=$(get_coords)

    # If Up ALSO failed, we have no vertical neighbors.
    # Force layout change to Vertical.
    if [[ "$start_coords" == "$check2" ]]; then
      hyprctl dispatch togglesplit
    fi
  fi
fi
