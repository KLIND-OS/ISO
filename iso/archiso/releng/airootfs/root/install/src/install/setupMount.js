import isEFI from "../utils/uefi.js";
import ora from "ora";
import executeCommand from "../utils/executeCommand.js";

export default async function setupMountPoints(selectedDisk, lang) {
  const spinner = ora();

  const isUEFI = await isEFI();

  if (isUEFI) {
    await executeCommand(`mount ${selectedDisk}2 /mnt`, spinner, lang);
    await executeCommand(`mkdir -p /mnt/boot/efi`, spinner, lang);
    await executeCommand(`mount ${selectedDisk}1 /mnt/boot/efi`, spinner, lang);
  } else {
    await executeCommand(`mount ${selectedDisk}2 /mnt`, spinner, lang);
    await executeCommand(`mkdir /mnt/boot`, spinner, lang);
    await executeCommand(`mount ${selectedDisk}1 /mnt/boot`, spinner, lang);
  }
}
