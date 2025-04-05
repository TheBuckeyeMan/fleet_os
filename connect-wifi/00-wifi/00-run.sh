#!/bin/bash -e
install -m 600 files/wpa_supplicant.conf "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"
echo "Wi-Fi config installed on $(date)" >> "${ROOTFS_DIR}/boot/wifi-setup-log.txt"

#If we need to debug wifi, We can check the wifi-setup-log.txt file within the OS image