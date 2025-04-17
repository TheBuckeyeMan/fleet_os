#!/bin/bash -e

echo "[AP-SETUP] Installing Flask + setting up AP..." >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

on_chroot << EOF
apt-get update
apt-get install -y python3-flask dnsmasq network-manager

# Create AP mode using NetworkManager
nmcli connection add type wifi ifname wlan0 con-name ap-mode autoconnect yes ssid PiSetup
nmcli connection modify ap-mode wifi.mode ap
nmcli connection modify ap-mode 802-11-wireless.band bg
nmcli connection modify ap-mode 802-11-wireless.channel 6
nmcli connection modify ap-mode wifi-sec.key-mgmt wpa-psk
nmcli connection modify ap-mode wifi-sec.psk "raspberry"
nmcli connection modify ap-mode ipv4.addresses 192.168.4.1/24
nmcli connection modify ap-mode ipv4.method manual
nmcli connection up ap-mode
EOF


echo "[ap-setup - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

