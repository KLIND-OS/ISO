#!/bin/bash


if [ -e "/root/config/useDev" ]; then
  while true; do
    (cd /root/KLIND-OS-Client && npm startNoSandbox)
  done
else
  while true; do
    ~/client.AppImage --no-sandbox
  done
fi

