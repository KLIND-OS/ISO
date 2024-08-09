import ora from "ora";
import executeCommand from "../utils/executeCommand.js";
import isEFI from "../utils/uefi.js";
import JSON5 from "json5";
import fs from "fs/promises";
import path from "path";

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
  const UEFI = await isEFI();
  const filepath = path.join(
    import.meta.dirname,
    "..",
    "config",
    "packages.json5",
  );
  const packagesFile = await fs.readFile(filepath, { encoding: "utf8" });
  const packages = JSON5.parse(packagesFile).join(" ");

  await executeCommand(
    `mkdir /mnt/temp && cat > /mnt/temp/continue << EOF
ln -sf /usr/share/zoneinfo/${region}/${city} /etc/localtime
hwclock --systohc

mv /etc/locale.gen /etc/locale.gen.backup
touch /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
mv /etc/locale.conf /etc/locale.conf.backup
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
locale-gen

echo "${hostname}" >> /etc/hostname

echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $hostname.localdomain    $hostname" >> /etc/hosts
echo -e "${rootPass}\n${rootPass}" | passwd root

pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
if [ "${UEFI ? "yes" : "no"}" == "yes" ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck
else
    grub-install --target=i386-pc "${selectedDisk}"
fi
cp /etc/default/grub /etc/default/grub.backup

pacman -S --noconfirm ${DRI} ${packages}
systemctl enable NetworkManager
systemctl enable cups
systemctl enable bluetooth

touch ~/.xinitrc
echo "exec /usr/bin/pipewire &" >> ~/.xinitrc
echo "exec /usr/bin/pipewire-pulse &" >> ~/.xinitrc
echo "exec /usr/bin/pipewire-media-session &" >> ~/.xinitrc
echo "exec xmonad" >> ~/.xinitrc
EOF`,
    spinner,
    lang,
    "chroot-setup",
  );

  // Execute commands in chroot environment
  await executeCommand(
    `arch-chroot /mnt bash /temp/continue`,
    spinner,
    lang,
  );
}
