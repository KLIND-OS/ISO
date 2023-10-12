#!/bin/bash

primary_display=""
update_mirror() {
    connected_displays=($(xrandr --query | grep " connected" | awk '{print $1}'))
    if [ ${#connected_displays[@]} -lt 2 ]; then
        return
    fi

    if [ "$primary_display" != "${connected_displays[0]}" ]; then
        primary_display="${connected_displays[0]}"
        xrandr --output "$primary_display" --primary
    fi

    for display in "${connected_displays[@]}"; do
        if [ "$display" != "$primary_display" ]; then
            xrandr --output "$display" --same-as "$primary_display"
        fi
    done

}

# Initial update
update_mirror

# Monitor for changes in connected displays using inotifywait
while true; do
    inotifywait -e modify,create,delete /sys/class/drm/*/status
    update_mirror
done
