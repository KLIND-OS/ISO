rm -rf /root/nohup.out
nohup node ~/klindos-server/server.js &
nohup bash ~/automount/automount.sh &
startx

