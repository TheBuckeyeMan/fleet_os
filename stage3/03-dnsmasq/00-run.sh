#!/bin/bash -e

echo "[Stage 03-dnsmasq - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

# Install dnsmasq (force full version over base-only install)
on_chroot << EOF
apt-get update
apt-get install -y --allow-downgrades dnsmasq
EOF

# Copy config
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"
install -m 644 files/dnsmasq.service "${ROOTFS_DIR}/etc/systemd/system/dnsmasq.service"

# Enable dnsmasq service
on_chroot << EOF
systemctl enable dnsmasq
EOF

echo "[Stage 03-dnsmasq - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"



