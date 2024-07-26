import { exec } from "child_process";
import Cmd from "./cmd.js";

export default async function executeCommand(command, spinner, lang) {
  try {
    spinner.start(`${lang.getStr("executing")}: ${command}\n\n`);
    Cmd.endSection();

    const process = exec(command, { stdio: "pipe" });

    // Stream stdout
    process.stdout.on("data", (data) => {
      console.log(data.toString());
    });

    // Stream stderr
    process.stderr.on("data", (data) => {
      console.error(data.toString());
    });

    await new Promise((resolve, reject) => {
      process.on("close", (code) => {
        if (code === 0) {
          spinner.succeed(`${lang.getStr("success")}: ${command}`);
          resolve();
        } else {
          spinner.fail(`${lang.getStr("error")}: ${command}`);
          reject(new Error(`Command failed with exit code ${code}`));
        }
      });
      process.on("error", (error) => {
        spinner.fail(`${lang.getStr("error")}: ${command}`);
        reject(error);
      });
    });
  } catch (error) {
    Cmd.error(error.message);
    Cmd.endSection();
  }
  console.log("\n\n")
}
