#!/bin/bash

rm -rf /root/nohup.out
nohup node ~/klindos-server/server.js &
nohup node ~/usrfiles-server/index.js &
nohup node ~/appdata-server/index.js &
nohup bash ~/automount/automount.sh &
startx

