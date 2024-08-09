import inquirer from "inquirer";
import Cmd from "../utils/cmd.js";

export default async function promptHostname(lang, invalid = false) {
  if (invalid) {
    Cmd.error(lang.getStr("invalid_hostname"));
  }

  const { hostname } = await inquirer.prompt([
    {
      type: "input",
      name: "hostname",
      message: lang.getStr("select_hostname"),
    },
  ]);

  const isValidHostname = (name) => {
    const regex =
      /^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9](\.[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])*$/;
    return regex.test(name);
  };

  if (isValidHostname(hostname)) {
    return hostname;
  } else {
    return promptHostname(lang, true);
  }
}
