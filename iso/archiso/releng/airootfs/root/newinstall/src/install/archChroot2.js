import ora from "ora";
import executeCommand from "../utils/executeCommand.js";

export default async function archChroot2(branch, lang, mountPoint = "/mnt") {
  const spinner = ora();

  // Execute commands in chroot environment
  await executeCommand(
    `
arch-chroot ${mountPoint} <<EOF
grub-mkconfig -o /boot/grub/grub.cfg

git clone --depth 1 --branch ${branch} https://github.com/KLIND-OS/Client /root/KLIND-OS-Client
(cd /root/KLIND-OS-Client && npm install)
(cd /root/KLIND-OS-Client && npm run build)
cp /root/KLIND-OS-Client/dist/*.AppImage /root/client.AppImage
rm -rf /root/KLIND-OS-Client

(cd /root/klindos-server && npm install express)
(cd /root/usrfiles-server && npm install)
(cd /root/appdata-server && npm install)
mkdir /root/packages
(cd /root/packages && npm init -y)
xmonad --recompile
mkdir /etc/systemd/system/getty@tty1.service.d/
touch /etc/systemd/system/getty@tty1.service.d/autologin.conf
echo "[Service]" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
echo "ExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf

chmod +x ~/bin/close
EOF
`.trim(),
    spinner,
    lang,
    "arch-chroot",
  );
}
