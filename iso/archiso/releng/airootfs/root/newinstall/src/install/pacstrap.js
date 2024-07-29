import ora from "ora";
import executeCommand from "../utils/executeCommand.js";

export default async function pacStrap(lang) {
  const spinner = ora();

  await executeCommand(
    `pacstrap /mnt base linux linux-firmware`,
    spinner,
    lang,
  );
}
