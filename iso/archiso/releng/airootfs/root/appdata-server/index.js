const express = require("express")
const path = require("path")
const os = require("os")
const app = express();

app.use(express.static(path.join(os.homedir(), "appdata")));

app.listen(9998, "127.0.0.1", () => {
  console.log("AppData server started.")
});
