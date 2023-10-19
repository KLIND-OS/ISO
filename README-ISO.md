# KLIND OS Instalační ISO soubor a script

Toto je repozitář který obsahuje instalační script a generátor ISO souboru.

# Základní informace

Instalační script se nachází ve složce `/iso/install-scripts `a ve složce `/iso/archiso/releng/airootfs/root/`

Složka `/iso/archiso/releng/airootfs/root/` musí mít všechny soubory které jsou ve složce `/iso/install-scripts` a taky některé navíc.

Při spuštení instalačního systému se automaticky uživatel přihlásí do `root` uživatele a poté se spustí bash script který se nachází ve složce `install`. Script na automatické spuštění se nachází v souboru `.bash_profile` ve složce `/iso/archiso/releng/airootfs/root/`.

# Generování iso souboru

Pokud chcete generovat ISO soubor musíte být na operačním systému Arch Linux. (nebo takhle, asi nemusíte ale mám to otestované pouze v Arch Linuxu) Poté si stáhnete program archiso pomocí

```shell
sudo pacman -S archiso
```

Následně v terminálu spusťte soubor `makeiso.sh`. Následně iso soubor bude ve složce `output`.
