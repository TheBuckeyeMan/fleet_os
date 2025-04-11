#!/bin/bash -e

echo "[Stage 03-dnsmasq - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

# Install dnsmasq inside chroot
on_chroot << EOF
apt-get update
apt-get install -y dnsmasq
EOF

# Copy dnsmasq config
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"

# Optional: Add custom service file if using one
install -m 644 files/dnsmasq.service "${ROOTFS_DIR}/etc/systemd/system/dnsmasq.service"

# Enable dnsmasq
on_chroot << EOF
systemctl enable dnsmasq
EOF

echo "[Stage 03-dnsmasq - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"


