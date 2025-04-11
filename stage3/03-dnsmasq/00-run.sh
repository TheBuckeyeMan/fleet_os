#!/bin/bash -e

echo "[Stage 03-dnsmasq - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

# Install dnsmasq-base
on_chroot << EOF
apt-get update
apt-get install -y dnsmasq-base
EOF

# Copy config + custom service
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"
install -m 644 files/dnsmasq.service "${ROOTFS_DIR}/etc/systemd/system/dnsmasq.service"

on_chroot << EOF
systemctl enable dnsmasq.service
EOF

echo "[Stage 03-dnsmasq - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

