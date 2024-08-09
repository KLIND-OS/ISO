import Cmd from "../utils/cmd.js";
import { exec } from "child_process";
import { promisify } from "util";
import inquirer from "inquirer";
const execPromise = promisify(exec);

export default async function printFinishPage(lang) {
  Cmd.clear();
  Cmd.section(lang.getStr("done"));
  console.log(lang.getStr("done_text"));
  Cmd.endSection();
  console.log("\n");

  const choices = [
    {
      name: lang.getStr("reboot"),
      value: "reboot",
    },
    {
      name: lang.getStr("poweroff"),
      value: "poweroff",
    },
  ];

  const { option } = await inquirer.prompt([
    {
      type: "list",
      name: "option",
      message: lang.getStr("select"),
      choices: choices,
    },
  ]);

  await execPromise(option);
}
