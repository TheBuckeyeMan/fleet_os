#!/bin/bash -e
echo "[hostapd - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

on_chroot << EOF
apt-get update
apt-get install -y hostapd
EOF

echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> "${ROOTFS_DIR}/etc/default/hostapd"
install -d "${ROOTFS_DIR}/etc/hostapd"
install -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"

on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
EOF

echo "[hostapd - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"



