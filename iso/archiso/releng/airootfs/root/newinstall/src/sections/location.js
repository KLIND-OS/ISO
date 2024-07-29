import fs from "fs/promises";
import fsnor from "fs";
import inquirer from "inquirer";

async function getRegions() {
  const zoneInfoPath = "/usr/share/zoneinfo";
  const regions = await fs.readdir(zoneInfoPath);
  return regions.filter((region) => {
    const stats = fsnor.statSync(`${zoneInfoPath}/${region}`);
    return stats.isDirectory();
  });
}

async function getCities(region) {
  const cities = await fs.readdir(`/usr/share/zoneinfo/${region}`);
  return cities;
}

export default async function selectRegionAndCity(lang) {
  const regions = await getRegions();
  const regionChoices = regions.map((region) => ({
    name: region,
    value: region,
  }));

  const { selectedRegion } = await inquirer.prompt([
    {
      type: "list",
      name: "selectedRegion",
      message: lang.getStr("select_region"),
      choices: regionChoices,
      pageSize: 10,
    },
  ]);

  const cities = await getCities(selectedRegion);
  const cityChoices = cities.map((city) => ({ name: city, value: city }));

  const { selectedCity } = await inquirer.prompt([
    {
      type: "list",
      name: "selectedCity",
      message: await lang.getStr("select_city"),
      choices: cityChoices,
      pageSize: 10,
    },
  ]);

  return [selectedRegion, selectedCity];
}
