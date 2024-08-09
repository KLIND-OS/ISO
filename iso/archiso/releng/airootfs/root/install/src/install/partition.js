import ora from "ora";
import executeCommand from "../utils/executeCommand.js";
import isEFI from "../utils/uefi.js"

export default async function partitionDisk(disk, lang) {
  const spinner = ora();

  await executeCommand(`wipefs -a ${disk}`, spinner, lang);

  if (await isEFI()) {
    await executeCommand(`parted ${disk} mklabel gpt`, spinner, lang);
    await executeCommand(
      `parted -a opt ${disk} mkpart primary fat32 1MiB 551MiB`,
      spinner,
      lang,
    );
    await executeCommand(`parted -a opt ${disk} set 1 boot on`, spinner, lang);
    await executeCommand(
      `parted -a opt ${disk} mkpart primary ext4 551MiB 100%`,
      spinner,
    );
    await executeCommand(`mkfs.fat -F32 ${disk}1`, spinner, lang);
    await executeCommand(`mkfs.ext4 -F ${disk}2`, spinner, lang);
  } else {
    await executeCommand(`parted ${disk} mklabel msdos`, spinner, lang);
    await executeCommand(
      `parted -a opt ${disk} mkpart primary ext4 1MiB 500MiB`,
      spinner,
      lang,
    );
    await executeCommand(
      `parted -a opt ${disk} mkpart primary ext4 500MiB 100%`,
      spinner,
      lang,
    );
    await executeCommand(`mkfs.ext4 -F ${disk}1`, spinner, lang);
    await executeCommand(`mkfs.ext4 -F ${disk}2`, spinner, lang);
  }
}
