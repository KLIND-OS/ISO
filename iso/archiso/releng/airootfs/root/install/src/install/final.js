import ora from "ora";
import executeCommand from "../utils/executeCommand.js";

export default async function final(lang) {
  const spinner = ora();

  await executeCommand(`genfstab -U /mnt >> /mnt/etc/fstab`, spinner, lang);
  await executeCommand(`sed -i '/\/dev\/zram/d' /mnt/etc/fstab`, spinner, lang);
  await executeCommand(`umount -R /mnt`, spinner, lang);
}
