import inquirer from "inquirer";

export default async function selectDriver(lang) {
  const drivers = [
    { name: "Intel", value: "xf86-video-intel" },
    { name: "AMD", value: "xf86-video-amdgpu" },
    { name: "NVIDIA", value: "nvidia nvidia-settings nvidia-utils" },
    { name: "VirtualBox", value: "xf86-video-fbdev" },
    { name: lang.getStr("skip_drivers"), value: "" },
  ];

  const { selectedDriver } = await inquirer.prompt([
    {
      type: "list",
      name: "selectedDriver",
      message: lang.getStr("select_drivers"),
      choices: drivers,
      pageSize: 10,
    },
  ]);

  return selectedDriver;
}
