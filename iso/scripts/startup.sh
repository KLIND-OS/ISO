function main() {
    optio=("Spustit KLIND OS" "Aktualizovat KLIND OS a systém" "Restartovat" "Otrevrit linux prikazovy radek")
    options=()
    for option in "${optio[@]}"; do
        options+=("$option" "")
    done
    option=$(dialog --nocancel --title "Start" --menu "Vyberte co se má stát:" 10 40 3 "${options[@]}" 3>&1 1>&2 2>&3)

    case "$option" in
        "Spustit KLIND OS")
            nohup node ~/klindos-server/server.js &
            startx
            ;;
        "Aktualizovat KLIND OS a systém")
            pacman -Suy --noconfirm
            rm -rf /root/klindos-server/data
            git clone https://github.com/JZITNIK-github/KLIND-OS-Demo-Server /root/klindos-server/data
            dialog --title "Hotovo!" --msgbox "KLIND OS a systém byl aktualizován!" 10 30  3>&1 1>&2 2>&3
            main
            ;;
        "Restartovat")
            reboot
            ;;
        "Otrevrit linux prikazovy radek")
            exit
            ;;
        *)
            dialog --title "Chyba!" --msgbox "Neplatná volba" 10 30  3>&1 1>&2 2>&3
            main
            ;;
    esac
}

main