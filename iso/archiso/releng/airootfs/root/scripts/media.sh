#!/bin/bash
case $1 in
up)
	pamixer -u
	pamixer -i 5 --allow-boost
	python sendMessageToUI.py "AudioEditor.popup.volumeUp()"
	;;
down)
	pamixer -u
	pamixer -d 5 --allow-boost
	python sendMessageToUI.py "AudioEditor.popup.volumeDown()"
	;;
mute)
	pamixer -t
    python sendMessageToUI.py "AudioEditor.popup.volumeMute()"
	;;
play-pause)
	playerctl play-pause
    python sendMessageToUI.py "AudioEditor.popup.pause()"
	;;
previous)
	playerctl previous
    python sendMessageToUI.py "AudioEditor.popup.previous()"
	;;
next)
	playerctl next
    python sendMessageToUI.py "AudioEditor.popup.next()"
	;;
esac