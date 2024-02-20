const express = require("express")
const path = require("path")
const os = require("os")
const app = express();

app.use(express.static(path.join(os.homedir(), "usrfiles")));

app.listen(9999, "127.0.0.1", () => {
  console.log("FileManager server started.")
});
