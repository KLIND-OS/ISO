#!/bin/bash

options="Nastavení zvuku\nNastavení internetu\nZavřít"

selected_option=$(echo -e "${options[@]}" | rofi -dmenu -p "Vyberte nastavení:")
notify-send "Pro zavření okna stiskněte Win + Shift + C"
case "$selected_option" in
    "Nastavení zvuku")
        pavucontrol
        ;;
    "Nastavení internetu")
        nm-connection-editor
        ;;
    *)
        # Handle other/invalid selections
        ;;
esac
