import inquirer from "inquirer";
import { exec } from "child_process";

function getKeyboardLayouts() {
  return new Promise((resolve, reject) => {
    exec("localectl list-x11-keymap-layouts", (error, stdout, stderr) => {
      if (error) {
        reject(`Error fetching keyboard layouts: ${stderr}`);
      } else {
        const layouts = stdout.split("\n").filter((layout) => layout);
        resolve(layouts);
      }
    });
  });
}

function getKeyboardVariants(layout) {
  return new Promise((resolve, reject) => {
    exec(
      "localectl list-x11-keymap-variants " + layout,
      (error, stdout, stderr) => {
        if (error) {
          reject(`Error fetching keyboard layouts: ${stderr}`);
        } else {
          const layouts = stdout.split("\n").filter((layout) => layout);
          resolve(layouts);
        }
      },
    );
  });
}

export async function selectKeyboardLayout(lang) {
  const layouts = await getKeyboardLayouts();
  const { layout } = await inquirer.prompt([
    {
      type: "list",
      name: "layout",
      message: lang.getStr("select_keyboard"),
      choices: layouts,
      pageSize: 20,
    },
  ]);

  const variants = await getKeyboardVariants(layout);
  const { variant } = await inquirer.prompt([
    {
      type: "list",
      name: "variant",
      message: lang.getStr("select_keyboard_variant"),
      choices: [lang.getStr("default"), ...variants],
      pageSize: 20,
    },
  ]);

  return {
    layout,
    variant: variant == lang.getStr("default") ? null : variant,
  };
}
