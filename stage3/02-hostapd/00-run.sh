#!/bin/bash -e
echo "[Stage X - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"


apt-get update
apt-get install -y hostapd

echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> "${ROOTFS_DIR}/etc/default/hostapd"

# Create the directory if not exists
install -d "${ROOTFS_DIR}/etc/hostapd"

# Now install the config
install -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"

on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
EOF

echo "[Stage X - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"
