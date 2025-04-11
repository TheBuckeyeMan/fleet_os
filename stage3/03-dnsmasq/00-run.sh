#!/bin/bash -e
echo "[dnsmasq - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

on_chroot << EOF
apt-get update
apt-get install -y dnsmasq
EOF

install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"
install -m 644 files/dnsmasq.service "${ROOTFS_DIR}/etc/systemd/system/dnsmasq.service"

on_chroot << EOF
systemctl enable dnsmasq
EOF

echo "[dnsmasq - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"


