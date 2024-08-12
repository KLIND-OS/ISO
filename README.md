# KLIND OS Installation ISO file and script

This is repository that contains KLIND OS installaction script.

# Basic info

Installation script is located here: `/iso/archiso/releng/airootfs/root/`

After starting the ISO you will be automatically loged in as a `root` and then it will execute script that is inside of `install` folder.

# Generating ISO file

If you want to generate your own ISO file you need to be on Arch Linux. Then you need to install program call archiso using this command:

```shell
sudo pacman -S archiso
```

After that in the terminal run this:

```
cd iso/archiso
sudo bash makeiso.sh
```

This will then generate the ISO file and sha256 and put it in `final` folder.
