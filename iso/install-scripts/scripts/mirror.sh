#!/bin/bash

# Get the primary monitor by checking which monitor has the "primary" status
PRIMARY_MONITOR=$(xrandr --listmonitors | grep "+.*$" | awk '{print $4}')

# Get a list of all connected monitors, excluding the primary monitor
connected_monitors=$(xrandr | grep " connected" | awk '{print $1}' | grep -v "$PRIMARY_MONITOR")

# Loop through each connected monitor and mirror it with the primary monitor
for monitor in $connected_monitors; do
  xrandr --output "$monitor" --same-as "$PRIMARY_MONITOR"
done
