import ora from "ora";
import executeCommand from "../utils/executeCommand.js";
import isEFI from "../utils/uefi.js";

export default async function archChroot(
  hostname,
  rootPass,
  selectedDisk,
  DRI,
  region,
  city,
  lang,
) {
  const spinner = ora();
  const UEFI = isEFI();

  const commands = `
ln -sf /usr/share/zoneinfo/${region}/${city} /etc/localtime
hwclock --systohc

mv /etc/locale.gen /etc/locale.gen.backup
touch /etc/locale.gen
echo "cs_CZ.UTF-8 UTF-8" >> /etc/locale.gen
mv /etc/locale.conf /etc/locale.conf.backup
echo "LANG=cs_CZ.UTF-8" >> /etc/locale.conf
locale-gen

echo ${hostname} >> /etc/hostname

echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    ${hostname}.localdomain    ${hostname}" >> /etc/hosts
echo -e "${rootPass}\\n${rootPass}" | passwd root

pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
${UEFI ? `grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck` : `grub-install --target=i386-pc ${selectedDisk}`}
cp /etc/default/grub /etc/default/grub.backup

pacman -S --noconfirm ${DRI} nano git networkmanager xorg xorg-xinit picom alacritty chromium base-devel xmonad xmonad-contrib nodejs dialog npm fuse2 pipewire pipewire-pulse pipewire-media-session pavucontrol dunst libnotify nm-connection-editor rofi inotify-tools gparted pamixer playerctl cups bluez bluez-utils blueberry iwd ntfs-3g acpi numlockx xf86-input-synaptics maim unzip zip

systemctl enable NetworkManager
systemctl enable cups
systemctl enable bluetooth

touch ~/.xinitrc
echo "exec /usr/bin/pipewire &" >> ~/.xinitrc
echo "exec /usr/bin/pipewire-pulse &" >> ~/.xinitrc
echo "exec /usr/bin/pipewire-media-session &" >> ~/.xinitrc
echo "exec xmonad" >> ~/.xinitrc
`;

  // Execute commands in chroot environment
  await executeCommand(
    `arch-chroot ${mountPoint} /bin/bash -c "${commands.replace(/\n/g, " && ")}"`,
    spinner,
    lang,
  );
}
