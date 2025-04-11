#!/bin/bash -e

echo "[Stage 02-hostapd - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

# 1. Install hostapd inside chroot
on_chroot << EOF
apt-get update
apt-get install -y hostapd
EOF

# 2. Configure hostapd to use custom config
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> "${ROOTFS_DIR}/etc/default/hostapd"

# Ensure directory exists
install -d "${ROOTFS_DIR}/etc/hostapd"

# 3. Copy config
install -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"

# 4. Unmask + Enable hostapd inside chroot AFTER config exists
on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
EOF

echo "[Stage 02-hostapd - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"


