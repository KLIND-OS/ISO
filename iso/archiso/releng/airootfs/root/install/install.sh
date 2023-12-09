#!/bin/bash
scriptVersion="1.1"
backendStatusUrl="https://backend.jzitnik.is-a.dev/status"
backendVersionsUrl="https://backend.jzitnik.is-a.dev/klindos/installScript/supportedVersion"
backendBranchesUrl="https://backend.jzitnik.is-a.dev/klindos/branches/getAll"
githubUrl="https://github.com/JZITNIK-github/KLIND-OS-Server"
root_pass="1234"


echo "-> Spouštím KLIND OS instalačni script..."
locale-gen
echo "-> Testuji status všech služeb"

# Check backend
backendResponse=$(curl -s -o /dev/null -w "%{http_code}" "$backendStatusUrl")
if [ "$backendResponse" -eq 200 ]; then
    backendStatus="Backend: \Z2Funguje\Zn"
else
    backendStatus="Backend: \Z1Nefunguje\Zn"
fi

# Check github
githubResponse=$(curl -s -o /dev/null -w "%{http_code}" "$githubUrl")
if [ "$githubResponse" -eq 200 ]; then
    githubResponse="Github: \Z2Funguje\Zn"
else
    githubResponse="Github: \Z1Nefunguje\Zn"
fi

echo "-> Testuji jestli je script aktuální"
scriptVersionResponse=$(curl -s "$backendVersionsUrl")
if [[ $scriptVersionResponse =~ ^\[.*\]$ ]]; then
    array=($(echo "$scriptVersionResponse " | jq -r '.[]'))
    if [[ " ${array[@]} " =~ " $scriptVersion" ]]; then
      echo "-> Script je aktuální!"
    else
      dialog \
        --colors \
        --title "Zastaralý instalační program" \
        --msgbox "\Z1!!! POZOR !!!\Zn\n\nInstalační program není aktuální!. ISO které používáte je zastaralé a není aktuální. Prosím stáhněte si novou verzi instalačního souboru.\nVerze kterou používáte: \Z1$scriptVersion\Zn" \
        10 50
      printf "\n\n\nInfo:\nPro vypnutí počítače napište 'poweroff'.\nPro restart napište 'reboot'."
      exit 1
    fi
else
    echo "-> Chyba: Invalidní JSON odpověd od backendu!"
    echo "-> Pozor: Nebylo možné zjistit jestli je script aktuální!"
    echo "-> Script nemusí fungovat správně!"
    echo "-> Čekám 5 sekund..."
    sleep 5
fi

dialog \
  --colors \
  --title "KLIND OS" \
  --msgbox "Vítejte v instalaci KLIND OS.\n\n\Z1!!! UPOZORNĚNÍ !!!\Zn\nTento script nemusí fungovat správně.\nPři instalaci doporučuji odpojit všechny ostatní disky kromě disku s ISO souborem a disku na který chcete nainstalovat KLIND OS.\n\nStatus služeb:\n$backendStatus\n$githubResponse\n\nInformace:\nVerze scriptu: $scriptVersion \Z2(aktuální)\Zn\n\n\nKLIND OS Installation script.\nNapsal Jakub Žitník. Napsáno v bash.\nGithub: jzitnik.is-a.dev/link/klindos-install-script" \
  25 60

     
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

function select_disk_dialog() {
    local disks=()
    local dialog_options=()

    while IFS= read -r line; do
        local disk_name=$(udevadm info -n "$line" -q property | grep "ID_MODEL=" | cut -d'=' -f2)
        local disk_size_bytes=$(lsblk -bdno SIZE "$line")
        
        if [ -n "$disk_name" ]; then
            local disk_size_human=""
            local size="$disk_size_bytes"

            if ((size > 1099511627776)); then
                disk_size_human=$(awk "BEGIN{printf \"%.2f TiB\",${size}/1099511627776}")
            elif ((size > 1073741824)); then
                disk_size_human=$(awk "BEGIN{printf \"%.2f GiB\",${size}/1073741824}")
            elif ((size > 1048576)); then
                disk_size_human=$(awk "BEGIN{printf \"%.2f MiB\",${size}/1048576}")
            elif ((size > 1024)); then
                disk_size_human=$(awk "BEGIN{printf \"%.2f KiB\",${size}/1024}")
            else
                disk_size_human="${size} Bytes"
            fi
            
            disks+=("$line $disk_name $disk_size_human $disk_fstype")
            dialog_options+=("$line" "Jméno: $disk_name, Velikost: $disk_size_human")
        fi
    done < <(lsblk -rno NAME,TYPE | awk '$2=="disk" {print "/dev/"$1}')

    local selected_disk_info=$(dialog --nocancel --menu "Vyberte disk na který chcete nainstalovat KLIND OS:" 12 80 4 "${dialog_options[@]}" 3>&1 1>&2 2>&3)

    local selected_disk=$(echo "$selected_disk_info" | cut -d' ' -f1)
    
    echo "$selected_disk"
}

function partition_disk() {
    local disk="$1"
    wipefs -a "$disk"
    if [ -d "/sys/firmware/efi" ]; then
        parted "$disk" mklabel gpt  
        parted -a opt "$disk" mkpart primary fat32 1MiB 551MiB
        parted -a opt "$disk" set 1 boot on
        parted -a opt "$disk" mkpart primary ext4 551MiB 100%  
        mkfs.fat -F32 "${disk}1"
        mkfs.ext4 -F "${disk}2"
    else
        parted "$disk" mklabel msdos  
        parted -a opt "$disk" mkpart primary ext4 1MiB 500MiB
        parted -a opt "$disk" mkpart primary ext4 500MiB 100%  
        mkfs.ext4 -F "${disk}1"
        mkfs.ext4 -F "${disk}2"
    fi
}


selected_disk=$(select_disk_dialog)


regions=( $(ls /usr/share/zoneinfo/) )
regions_options=()
for option in "${regions[@]}"; do
    regions_options+=("$option" "")
done
region=$(dialog --nocancel --menu "Vyberte region:" 30 40 3 "${regions_options[@]}" 3>&1 1>&2 2>&3)
cities=( $(ls /usr/share/zoneinfo/$region/) )
cities_options=()
for option in "${cities[@]}"; do
    cities_options+=("$option" "")
done
city=$(dialog --nocancel --menu "Vyberte město:" 30 40 3 "${cities_options[@]}" 3>&1 1>&2 2>&3)

function select_hostname() {
    if [[ $1 == true ]]; then
        hostname=$(dialog --nocancel --title "Název počítače" --inputbox "Byl zadán neplatný název počítače" 10 30 3>&1 1>&2 2>&3)
    else
        hostname=$(dialog --nocancel --title "Název počítače" --inputbox "Nastavte název počítače (hostname):" 10 30 3>&1 1>&2 2>&3)
    fi
    if [[ $hostname =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9](\.[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])*$ ]]; then
        echo "$hostname"
    else
        select_hostname true
    fi
}

hostname=$(select_hostname)


drivers=("Intel" "AMD" "NVIDIA" "Virtual box" "Přeskočit instalaci ovladačů")
drivers_options=()
for option in "${drivers[@]}"; do
    drivers_options+=("$option" "")
done
driver=$(dialog --nocancel --menu "Vyberte ovladač pro grafickou kartu:" 15 40 3 "${drivers_options[@]}" 3>&1 1>&2 2>&3)

case "$driver" in
    "Intel")
        DRI='xf86-video-intel'
        ;;
    "AMD")
        DRI='xf86-video-amdgpu'
        ;;
    "NVIDIA")
        DRI='nvidia nvidia-settings nvidia-utils'
        ;;
    "Virtual box")
        DRI='xf86-video-fbdev'
        ;;
    "Přeskočit instalaci ovladačů")
        DRI=''
        ;;
    *)
        DRI=''
        ;;
esac

echo "-> Získávám informace o branches z backendu!"
branches_response=$(curl -s "$backendBranchesUrl" )
if [ $? -eq 0 ]; then
  branches=($(echo $branches_response | jq -r '.[]'))
  branches_options=()
  for option in "${branches[@]}"; do
      branches_options+=("$option" "")
  done
  branch=$(dialog --nocancel --menu "Vyberte postavení systému chcete používat. Doporučuji 'main' (stable)." 10 40 3 "${branches_options[@]}" 3>&1 1>&2 2>&3)
else
  echo "-> Error: Nepovedlo se získat data z API. Používám výchozí branch: main";
fi

# Start the script

# Make the partitions
partition_disk "$selected_disk"

# Test UEFI
UEFI="no"
if [ -d "/sys/firmware/efi" ]; then
    UEFI="yes"
fi

if [ "$UEFI" == "yes" ]; then
    mount "${selected_disk}2" /mnt
    mkdir -p /mnt/boot/efi
    mount "${selected_disk}1" /mnt/boot/efi
else
    mount "${selected_disk}2" /mnt
    mkdir /mnt/boot
    mount "${selected_disk}1" /mnt/boot
fi

# Install basic packages
pacstrap /mnt base linux linux-firmware 


arch-chroot /mnt <<EOF
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc

mv /etc/locale.gen /etc/locale.gen.backup
touch /etc/locale.gen
echo "cs_CZ.UTF-8 UTF-8" >> /etc/locale.gen
mv /etc/locale.conf /etc/locale.conf.backup
echo "LANG=cs_CZ.UTF-8" >> /etc/locale.conf
locale-gen

echo $hostname >> /etc/hostname

echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $hostname.localdomain    $hostname" >> /etc/hosts
echo -e "$root_pass\n$root_pass" | passwd root

pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
if [ "$UEFI" == "yes" ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck
else
    grub-install --target=i386-pc "$selected_disk"
fi
cp /etc/default/grub /etc/default/grub.backup

pacman -S --noconfirm $DRI nano git networkmanager xorg xorg-xinit picom alacritty chromium base-devel xmonad xmonad-contrib nodejs dialog npm fuse2 pipewire pipewire-pulse pavucontrol dunst libnotify nm-connection-editor rofi inotify-tools gparted pamixer playerctl cups bluez bluez-utils blueman
systemctl enable NetworkManager
systemctl enable cups
systemctl enable bluetooth

touch ~/.xinitrc
echo "exec /usr/bin/pipewire &" >> ~/.xinitrc
echo "exec /usr/bin/pipewire-pulse &" >> ~/.xinitrc
echo "exec /usr/bin/pipewire-media-session &" >> ~/.xinitrc
echo "exec xmonad" >> ~/.xinitrc

EOF

# Copy and make all the needed files
mkdir /mnt/root/klindos-server
cp ~/scripts/startup.sh /mnt/root/
cp ~/scripts/selectprogram.sh /mnt/root/
cp ~/scripts/server.js /mnt/root/klindos-server
mkdir /mnt/root/scripts
cp ~/scripts/media.sh /mnt/root/scripts
cp ~/scripts/sendMessageToUI.py /mnt/root/scripts
cp ~/scripts/mirror.sh /mnt/root/scripts
touch /mnt/root/.bash_profile
echo "bash ~/startup.sh" >> /mnt/root/.bash_profile
mkdir /mnt/root/.xmonad
cp ~/config/xmonad.hs /mnt/root/.xmonad/
git clone --depth 1 https://github.com/JZITNIK-github/KLIND-OS-Server /mnt/root/klindos-server/data
cp ~/config/grub /mnt/etc/default/grub
cp -r ~/automount /mnt/root/
rm -rf /mnt/etc/cups/cupsd.conf
cp ~/config/cupsd.conf /mnt/etc/cups
touch /mnt/root/scripts_run.json
echo "[]" >> /mnt/root/scripts_run.json
mv /mnt/etc/vconsole.conf /mnt/etc/vconsole.conf.backup
cp ~/config/vconsole.conf /mnt/etc/vconsole.conf
touch /mnt/root/branch
echo "$branch" >> /mnt/root/branch

arch-chroot /mnt <<EOF
grub-mkconfig -o /boot/grub/grub.cfg
git clone --depth 1 https://github.com/JZITNIK-github/KLIND-OS-Client /root/KLIND-OS-Client
(cd /root/KLIND-OS-Client && npm install)
(cd /root/KLIND-OS-Client && npm run build)
cp /root/KLIND-OS-Client/dist/*.AppImage /root/client.AppImage
rm -rf /root/KLIND-OS-Client

(cd /root/klindos-server && npm install express)
xmonad --recompile
mkdir /etc/systemd/system/getty@tty1.service.d/
touch /etc/systemd/system/getty@tty1.service.d/autologin.conf
echo "[Service]" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
echo "ExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
EOF

genfstab -U /mnt >> /mnt/etc/fstab
sed -i '/\/dev\/zram/d' /mnt/etc/fstab
umount -R /mnt

echo "-> KLIND OS byl nainstalován! Napište 'reboot' pro restart"
