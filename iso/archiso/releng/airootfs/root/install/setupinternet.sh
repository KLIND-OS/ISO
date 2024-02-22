#!/bin/bash

dialog \
  --colors \
  --title "KLIND OS" \
  --msgbox "Internet nefunguje!\n\nPřipojte internet nebo nastavte wifi pomocí iwctl." \
  25 60

echo "Napište příkaz:"
echo "reboot: Restartuje pc"
echo "exit: Vypne příkazový řádek a otevře instalaci"
echo "iwctl: Otevře nastavení wifi"
