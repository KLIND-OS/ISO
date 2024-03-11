#!/bin/bash

primary_display=""
update_mirror() {
    connected_displays=($(xrandr --query | grep " connected" | awk '{print $1}'))
    xrandr --auto
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

    xrandr --auto
}

update_mirror
while true; do
    current_displays=$(xrandr --query | grep " connected" | awk '{print $1}')
    if [ "$current_displays" != "$prev_displays" ]; then
        update_mirror
        prev_displays="$current_displays"
    fi
    sleep 2
done
