import inquirer from "inquirer";
import JSON5 from "json5";
import path from "path";
import { promises as fs } from "fs";
import Cmd from "../utils/cmd.js";

const languages = [
  {
    name: "English",
    value: "en",
  },
  {
    name: "Čeština",
    value: "cs",
  },
];

class Lang {
  lang;
  strings;

  static async getLang() {
    // Show language selector for user
    const { language } = await inquirer.prompt([
      {
        type: "list",
        name: "language",
        message: "Select language",
        choices: languages,
      },
    ]);

    Cmd.info("Loading languages");

    const lang = new Lang(language);

    await lang.loadLang();

    return lang;
  }

  constructor(lang) {
    // DO NOT USE THIS CONSTRUCTOR. USE `Lang.getLang()` instead
    this.lang = lang;
  }

  async loadLang() {
    const filepath = path.join(import.meta.dirname, this.lang, "strings.json5");
    const content = await fs.readFile(filepath, {
      encoding: "utf8",
    });
    const strings = JSON5.parse(content);
    this.strings = strings;

    Cmd.success(this.getStr("language_loaded"));
  }

  getStr(key) {
    const str = this.strings[key];
    if (!str) {
      throw new Error("String not found: " + key);
    }

    return str;
  }
}

export default Lang;
