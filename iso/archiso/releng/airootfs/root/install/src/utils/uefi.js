import { exec } from "child_process";
import { promisify } from "util";
const execAsync = promisify(exec);

export default async function isEFI() {
  try {
    await execAsync("test -d /sys/firmware/efi");
    return true;
  } catch {
    return false;
  }
}
