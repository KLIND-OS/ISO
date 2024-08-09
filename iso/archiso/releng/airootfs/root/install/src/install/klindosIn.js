import executeCommand from "../utils/executeCommand.js";
import ora from "ora";
import fs from "fs/promises";

export default async function klindosIn(branch, { layout, variant }, lang) {
  const spinner = ora();

  await executeCommand(`mkdir /mnt/root/klindos-server`, spinner, lang);
  await executeCommand(`cp ~/scripts/startup.sh /mnt/root/`, spinner, lang);
  await executeCommand(`cp ~/scripts/server.js /mnt/root/klindos-server`, spinner, lang);
  await executeCommand(`mkdir /mnt/root/scripts`, spinner, lang);
  await executeCommand(`cp ~/scripts/media.sh /mnt/root/scripts`, spinner, lang);
  await executeCommand(`cp ~/scripts/sendMessageToUI.py /mnt/root/scripts`, spinner, lang);
  await executeCommand(`cp ~/scripts/mirror.sh /mnt/root/scripts`, spinner, lang);
  await executeCommand(`touch /mnt/root/.bash_profile`, spinner, lang);
  await executeCommand(`echo "bash ~/startup.sh" >> /mnt/root/.bash_profile`, spinner, lang);
  await executeCommand(`mkdir /mnt/root/.xmonad`, spinner, lang);
  await executeCommand(`cp ~/config/xmonad.hs /mnt/root/.xmonad/`, spinner, lang);
  await executeCommand(`git clone --depth 1 --branch "${branch}" https://github.com/KLIND-OS/Server /mnt/root/klindos-server/data`, spinner, lang);
  await executeCommand(`cp ~/config/grub /mnt/etc/default/grub`, spinner, lang);
  await executeCommand(`cp -r ~/automount /mnt/root/`, spinner, lang);
  await executeCommand(`cp -r ~/usrfiles-server /mnt/root/`, spinner, lang);
  await executeCommand(`cp -r ~/appdata-server /mnt/root/`, spinner, lang);
  await executeCommand(`rm -rf /mnt/etc/cups/cupsd.conf`, spinner, lang);
  await executeCommand(`cp ~/config/cupsd.conf /mnt/etc/cups`, spinner, lang);
  await executeCommand(`touch /mnt/root/scripts_run.json`, spinner, lang);
  await executeCommand(`echo "[]" >> /mnt/root/scripts_run.json`, spinner, lang);
  await executeCommand(`mv /mnt/etc/vconsole.conf /mnt/etc/vconsole.conf.backup`, spinner, lang);
  await executeCommand(`echo "${branch}" >> /mnt/root/branch`, spinner, lang);
  await executeCommand(`cp ~/scripts/startUI.sh /mnt/root/`, spinner, lang);
  await executeCommand(`mkdir /mnt/root/config`, spinner, lang);
  await executeCommand(`cp ~/scripts/closebtn.py /mnt/root/scripts`, spinner, lang);
  await executeCommand(`mkdir /mnt/root/usrfiles`, spinner, lang);
  await executeCommand(`cp ~/config/bashrc.sh /mnt/root/.bashrc`, spinner, lang);
  await executeCommand(`cp -r ~/bin /mnt/root/bin`, spinner, lang);
  await executeCommand(`cp ~/config/70-synaptics.conf /mnt/etc/X11/xorg.conf.d/70-synaptics.conf`, spinner, lang);

  if (variant !== null) {
    await fs.writeFile("/mnt/etc/X11/xorg.conf.d/00-keyboard.conf", `
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "${layout}"
        Option "XkbVariant" "${variant}"
EndSection`.trim());
  } else {
    await fs.writeFile("/mnt/etc/X11/xorg.conf.d/00-keyboard.conf", `
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "${layout}"
EndSection`.trim());
  }



  await executeCommand(`mkdir /mnt/root/appdata`, spinner, lang);
  await executeCommand(`if [ "$useDev" = true ]; then
  touch /mnt/root/config/useDev
fi`, spinner, lang, "touch /mnt/root/config/useDev");
}
