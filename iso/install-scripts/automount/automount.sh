#!/bin/bash
echo "Starting automount"
sudo umount -f /mnt/*
sudo rm -rf /mnt/*
initial_drives=($(lsblk -o NAME,TYPE -nr | awk '$2 == "disk" {print $1}'))
connected_drives=("${initial_drives[@]}")
while true; do
    inotifywait -q -e create,delete /dev
    block_devices=($(lsblk -o NAME,TYPE -nr | awk '$2 == "disk" {print $1}'))
    for device in "${block_devices[@]}"; do
        if [[ "$device" != loop* && "$device" != sr* ]]; then
            if ! [[ " ${connected_drives[@]} " =~ " ${device} " ]]; then
                connected_drives+=("$device")
                python ~/automount/automount_fs.py add $device
                partitions=($(lsblk -o NAME,TYPE,MOUNTPOINT -nr /dev/"$device" | awk '$2 == "part" && $3 == "" {print $1}'))

                # Mount each partition under /mnt
                for partition in "${partitions[@]}"; do
                    mount_point="/mnt/$partition"
                    if [ ! -d "$mount_point" ]; then
                        mkdir -p "$mount_point"
                    fi
                    mount "/dev/$partition" "$mount_point"
                done
            fi
        fi
    done


    for drive in "${connected_drives[@]}"; do
        if [[ ! " ${block_devices[@]} " =~ " ${drive} " ]]; then
            if [ -n "$drive" ]; then
                python ~/automount/automount_fs.py remove $drive
                # Unmount and remove all partitions associated with the drive
                for partition in /mnt/${drive}*; do
                    if [ -d "$partition" ]; then
                        umount -f "$partition"
                        rm -rf "$partition"
                    fi
                done
                connected_drives=("${connected_drives[@]/$drive}")
            fi
        fi
    done
done
