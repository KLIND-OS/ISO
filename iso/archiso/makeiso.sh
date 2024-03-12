#!/bin/bash

mkarchiso -v -w ./output -o ./output releng/
mkdir final
cp ./output/klindos*.iso ./final/KLINDOS.iso
rm -rf ./output
sha256sum ./final/KLINDOS.iso > ./final/KLINDOS.iso.sha256
