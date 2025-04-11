#!/bin/bash -e

echo "[Stage X - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"


# Disable wpa_supplicant entirely
on_chroot << EOF
systemctl disable wpa_supplicant
EOF

# Static IP for wlan0
echo -e "interface wlan0\n    static ip_address=192.168.4.1/24\n    nohook wpa_supplicant" >> "${ROOTFS_DIR}/etc/dhcpcd.conf"

# NetworkManager Ignore wlan0
mkdir -p "${ROOTFS_DIR}/etc/NetworkManager/conf.d"
cat << EOF > "${ROOTFS_DIR}/etc/NetworkManager/conf.d/ignore-wlan0.conf"
[keyfile]
unmanaged-devices=interface-name:wlan0
EOF

echo "[Stage X - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"