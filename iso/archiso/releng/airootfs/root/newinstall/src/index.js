import Lang from "./lang/langs.js";
import printWelcomePage from "./sections/welcomePage.js";
import checkInternet from "./utils/checkInternet.js";
import Cmd from "./utils/cmd.js";

Cmd.clear();
const lang = await Lang.getLang();

await checkInternet(lang);

await printWelcomePage(lang);
