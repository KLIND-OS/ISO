import { promisify } from "util";
import { exec as execCallback } from "child_process";
import inquirer from "inquirer";

const exec = promisify(execCallback);

async function getDiskInfo(lang) {
  const disks = [];
  const { stdout: lsblkOutput } = await exec("lsblk -rno NAME,TYPE");
  const diskLines = lsblkOutput
    .split("\n")
    .filter((line) => line.includes("disk"));

  for (const line of diskLines) {
    const device = `/dev/${line.split(" ")[0]}`;
    const { stdout: diskInfoOutput } = await exec(
      `udevadm info -n ${device} -q property`,
    );
    const diskNameLine = diskInfoOutput
      .split("\n")
      .find((line) => line.includes("ID_MODEL="));

    if (diskNameLine) {
      const diskName = diskNameLine.split("=")[1];
      const { stdout: diskSizeOutput } = await exec(
        `lsblk -bdno SIZE ${device}`,
      );
      const diskSizeBytes = parseInt(diskSizeOutput.trim(), 10);
      let diskSizeHuman = "";

      if (diskSizeBytes > 1099511627776) {
        diskSizeHuman = (diskSizeBytes / 1099511627776).toFixed(2) + " TiB";
      } else if (diskSizeBytes > 1073741824) {
        diskSizeHuman = (diskSizeBytes / 1073741824).toFixed(2) + " GiB";
      } else if (diskSizeBytes > 1048576) {
        diskSizeHuman = (diskSizeBytes / 1048576).toFixed(2) + " MiB";
      } else if (diskSizeBytes > 1024) {
        diskSizeHuman = (diskSizeBytes / 1024).toFixed(2) + " KiB";
      } else {
        diskSizeHuman = diskSizeBytes + " Bytes";
      }

      disks.push({
        name: device,
        displayName: `${lang.getStr("name")}: ${diskName}, ${lang.getStr("size")}: ${diskSizeHuman}`,
      });
    }
  }

  return disks;
}

export default async function selectDiskDialog(lang) {
  const disks = await getDiskInfo(lang);
  const choices = disks.map((disk) => ({
    name: disk.displayName,
    value: disk.name,
  }));

  const answers = await inquirer.prompt([
    {
      type: "list",
      name: "selectedDisk",
      message: lang.getStr("select_drive"),
      choices: choices,
    },
  ]);

  return answers.selectedDisk;
}
