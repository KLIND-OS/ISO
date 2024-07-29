import fetch from "node-fetch";
import Cmd from "./cmd.js";

export default async function checkInternet(lang) {
  Cmd.section(lang.getStr("internet"));
  Cmd.info(lang.getStr("checking_internet"));

  try {
    const response = await fetch("https://www.google.com");
    if (response.ok) {
      console.log("Internet connection is working.");
    } else {
      console.log("Internet connection is not working.");
    }
  } catch (error) {
    console.error("Error:", error);
    console.log("Internet connection is not working.");
  }
  Cmd.endSection();
}
