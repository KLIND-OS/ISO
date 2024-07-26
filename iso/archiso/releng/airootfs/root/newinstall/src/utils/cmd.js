import chalk from "chalk";
import middlePad from "./middlePad.js";
import inquirer from "inquirer";
import PressToContinuePrompt from "inquirer-press-to-continue";

inquirer.registerPrompt('press-to-continue', PressToContinuePrompt);

const noclear = false;

const Cmd = {
  section: (section) => console.log(middlePad(` ${section} `)),
  endSection: () => console.log(middlePad("") + "\n"),
  info: (message) => console.log(`${chalk.blue("Info:")} ${message}`),
  success: (message) => console.log(`${chalk.green("Success:")} ${message}`),
  warning: (message) => console.log(`${chalk.yellow("Warning:")} ${message}`),
  error: (message) => console.log(`${chalk.red("Error:")} ${message}`),
  clear: () => noclear || console.clear(),
  keyPress: async (msg) => {
    await inquirer.prompt({
      name: "key",
      type: "press-to-continue",
      anyKey: true,
      pressToContinueMessage: msg,
    });
  },
};

export default Cmd;
