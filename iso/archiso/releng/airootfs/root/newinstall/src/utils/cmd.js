import chalk from "chalk";
import middlePad from "./middlePad.js";
import readline from "readline";

const noclear = false;

const Cmd = {
  section: (section) => console.log(middlePad(` ${section} `)),
  endSection: () => console.log(middlePad("") + "\n"),
  info: (message) => console.log(`${chalk.blue("Info:")} ${message}`),
  success: (message) => console.log(`${chalk.green("Success:")} ${message}`),
  warning: (message) => console.log(`${chalk.yellow("Warning:")} ${message}`),
  error: (message) => console.log(`${chalk.red("Error:")} ${message}`),
  clear: () => noclear || console.clear(),
  pressEnter: (msg) => {
    return new Promise((resolve) => {
      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
      });

      rl.question(msg, () => {
        rl.close();
        resolve();
      });
    });
  },
};

export default Cmd;
