#!/bin/bash
root_pass="1234"

function select_disk_dialog() {
    local disks=($(lsblk -rno NAME,TYPE | awk '$2=="disk" {print "/dev/"$1}'))
    local dialog_options=()

    for disk in "${disks[@]}"; do
        dialog_options+=("$disk" "")
    done

    local selected_disk=$(dialog --nocancel --menu "Vyberte disk na ktery chcete nainstalovat KLIND OS:" 10 40 3 "${dialog_options[@]}" 3>&1 1>&2 2>&3)
    
    echo "$selected_disk"
}

function partition_disk() {
    local disk="$1"
    wipefs -a "$disk"
    parted "$disk" mklabel msdos  # Use msdos for MBR partitioning
    parted -a opt "$disk" mkpart primary ext4 1MiB 500MiB
    parted -a opt "$disk" mkpart primary ext4 500MiB 100%  # Create a single partition
    mkfs.ext4 -F "${disk}1"
    mkfs.ext4 -F "${disk}2"
}

# Select disk
selected_disk=$(select_disk_dialog)

# Locales
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
# Hostname
hostname=$(dialog --nocancel --title "Název počítače" --inputbox "Nastavte název počítače (hostname):" 10 30 3>&1 1>&2 2>&3)

# Drivers
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
# Mount the partition
mount "${selected_disk}2" /mnt
mkdir /mnt/boot
mount "${selected_disk}1" /mnt/boot

# Install the linux and base
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
grub-install --target=i386-pc "$selected_disk"  # Install bootloader to MBR
sed -i 's/GRUB_TIMEOUT=[0-9]\+/GRUB_TIMEOUT=0/' "/etc/default/grub"
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm $DRI nano git networkmanager xorg xorg-xinit picom alacritty firefox base-devel xmonad xmonad-contrib nodejs dialog npm fuse2 pipewire pipewire-pulse pavucontrol dunst libnotify nm-connection-editor
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
cp ~/bin/client.AppImage /mnt/root
git clone https://github.com/JZITNIK-github/KLIND-OS-Demo-Server /mnt/root/klindos-server/data

arch-chroot /mnt <<EOF
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


dialog --title "Hotovo!" --msgbox "Nyní se vám restartuje systém a budete moct používat KLIND OS." 10 30  3>&1 1>&2 2>&3 && reboot