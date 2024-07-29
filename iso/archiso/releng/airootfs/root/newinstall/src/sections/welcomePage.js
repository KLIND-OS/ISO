import Cmd from "../utils/cmd.js";
import middlePad from "../utils/middlePad.js";
import chalk from "chalk";

export default async function printWelcomePage(lang) {
  Cmd.clear();
  Cmd.section("KLIND OS");
  console.log(middlePad(lang.getStr("welcome"), 50, " "));
  console.log("\n");
  console.log(chalk.red(`!!! ${lang.getStr("attention")} !!!`));
  console.log(lang.getStr("attention_text"));
  Cmd.endSection();
  await Cmd.pressEnter(lang.getStr("press_key"));
  Cmd.clear();
}
