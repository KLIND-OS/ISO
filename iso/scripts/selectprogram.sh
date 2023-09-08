#!/bin/bash

options="Nastavení zvuku\nNastavení internetu\nZavřít"

selected_option=$(echo -e "${options[@]}" | rofi -dmenu -p "Vyberte nastavení:")

case "$selected_option" in
    "Nastavení zvuku")
        notify-send "Pro zavření okna stiskněte Win + Shift + C"
        pavucontrol
        ;;
    "Nastavení internetu")
        notify-send "Pro zavření okna stiskněte Win + Shift + C"
        nm-connection-editor
        ;;
    *)
        # Handle other/invalid selections
        ;;
esac
