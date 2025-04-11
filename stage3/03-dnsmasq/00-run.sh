#!/bin/bash -e

echo "[Stage 03-dnsmasq - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

# Update and Install dnsmasq
on_chroot << EOF
apt-get update
apt-get install -y dnsmasq-base
EOF

# Copy over dnsmasq config
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"

# Enable dnsmasq service
on_chroot << EOF
systemctl enable dnsmasq
EOF

echo "[Stage 03-dnsmasq - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"
