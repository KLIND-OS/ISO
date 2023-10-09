#!/bin/bash
root_pass="1234"

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

    local selected_disk_info=$(dialog --nocancel --menu "Vyberte disk na ktery chcete nainstalovat KLIND OS:" 12 80 4 "${dialog_options[@]}" 3>&1 1>&2 2>&3)

    local selected_disk=$(echo "$selected_disk_info" | cut -d' ' -f1)
    
    echo "$selected_disk"
}

function partition_disk() {
    local disk="$1"
    wipefs -a "$disk"
    parted "$disk" mklabel msdos  
    parted -a opt "$disk" mkpart primary ext4 1MiB 500MiB
    parted -a opt "$disk" mkpart primary ext4 500MiB 100%  
    mkfs.ext4 -F "${disk}1"
    mkfs.ext4 -F "${disk}2"
}


selected_disk=$(select_disk_dialog)


regions=( $(ls /usr/share/zoneinfo/) )
regions_options=()
for option in "${regions[@]}"; do
    regions_options+=("$option" "")
done
region=$(dialog --nocancel --menu "Vyberte region:" 10 40 3 "${regions_options[@]}" 3>&1 1>&2 2>&3)
cities=( $(ls /usr/share/zoneinfo/$region/) )
cities_options=()
for option in "${cities[@]}"; do
    cities_options+=("$option" "")
done
city=$(dialog --nocancel --menu "Vyberte mesto:" 10 40 3 "${cities_options[@]}" 3>&1 1>&2 2>&3)

hostname=$(dialog --nocancel --title "Název počítače" --inputbox "Nastavte název počítače (hostname):" 10 30 3>&1 1>&2 2>&3)


drivers=("Intel" "AMD" "NVIDIA" "Virtual box" "Přeskočit instalaci ovladačů")
drivers_options=()
for option in "${drivers[@]}"; do
    drivers_options+=("$option" "")
done
driver=$(dialog --nocancel --menu "Vyberte ovladač:" 10 40 3 "${drivers_options[@]}" 3>&1 1>&2 2>&3)

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

partition_disk "$selected_disk"

mount "${selected_disk}2" /mnt
mkdir /mnt/boot
mount "${selected_disk}1" /mnt/boot


pacstrap /mnt base linux linux-firmware 


arch-chroot /mnt <<EOF
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc

mv /etc/locale.gen /etc/locale.gen.backup
touch /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo $hostname >> /etc/hostname

echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $hostname.localdomain    $hostname" >> /etc/hosts
echo -e "$root_pass\n$root_pass" | passwd root

pacman -S --noconfirm grub
grub-install --target=i386-pc "$selected_disk"  
cp /etc/default/grub /etc/default/grub.backup

pacman -S --noconfirm $DRI nano git networkmanager xorg xorg-xinit picom alacritty chromium base-devel xmonad xmonad-contrib nodejs dialog npm fuse2 pipewire pipewire-pulse pavucontrol dunst libnotify nm-connection-editor rofi inotify-tools gparted pamixer playerctl
systemctl enable NetworkManager

touch ~/.xinitrc
echo "exec /usr/bin/pipewire &" >> ~/.xinitrc
echo "exec /usr/bin/pipewire-pulse &" >> ~/.xinitrc
echo "exec /usr/bin/pipewire-media-session &" >> ~/.xinitrc
echo "exec xmonad" >> ~/.xinitrc

EOF

mkdir /mnt/root/klindos-server
cp ~/scripts/startup.sh /mnt/root/
cp ~/scripts/selectprogram.sh /mnt/root/
cp ~/scripts/server.js /mnt/root/klindos-server
touch /mnt/root/.bash_profile
echo "bash ~/startup.sh" >> /mnt/root/.bash_profile
mkdir /mnt/root/.xmonad
cp ~/config/xmonad.hs /mnt/root/.xmonad/
git clone --depth 1 https://github.com/JZITNIK-github/KLIND-OS-Demo-Server /mnt/root/klindos-server/data
cp ~/config/grub /mnt/etc/default/grub
cp -r ~/automount /mnt/root/
touch /mnt/root/scripts_run.json
echo "[]" >> /mnt/root/scripts_run.json

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

echo ""
echo ""
echo ""
echo ""
echo ""
echo "Instalace byla hotova! Stiskněte enter pro pokračování..."
read
reboot