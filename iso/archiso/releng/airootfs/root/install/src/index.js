import archChroot from "./install/archChroot.js";
import archChroot2 from "./install/archChroot2.js";
import final from "./install/final.js";
import klindosIn from "./install/klindosIn.js";
import pacStrap from "./install/pacstrap.js";
import partitionDisk from "./install/partition.js";
import setupMountPoints from "./install/setupMount.js";
import Lang from "./lang/langs.js";
import selectDiskDialog from "./sections/diskSelector.js";
import selectDriver from "./sections/drivers.js";
import printFinishPage from "./sections/finishPage.js";
import promptHostname from "./sections/hostname.js";
import { selectKeyboardLayout } from "./sections/keyboard.js";
import selectRegionAndCity from "./sections/location.js";
import printWelcomePage from "./sections/welcomePage.js";
import checkInternet from "./utils/checkInternet.js";
import Cmd from "./utils/cmd.js";

const ROOT_PASS = "1234";

Cmd.clear();
const lang = await Lang.getLang();

await checkInternet(lang);
await printWelcomePage(lang);

// Prompts
const disk = await selectDiskDialog(lang);
const layout = await selectKeyboardLayout(lang);
const [region, city] = await selectRegionAndCity(lang);
const hostname = await promptHostname(lang);
const DRI = await selectDriver(lang);
const branch = "main"; // TODO: This is temporary.

// Install
await partitionDisk(disk, lang);
await setupMountPoints(disk, lang);
await pacStrap(lang);
await archChroot(hostname, ROOT_PASS, disk, DRI, region, city, lang);
await klindosIn(branch, layout, lang);
await archChroot2(branch, lang);
await final(lang);
await printFinishPage(lang);
