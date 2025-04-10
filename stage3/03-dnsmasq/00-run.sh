#!/bin/bash -e

echo "[Stage X - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"


apt-get install -y dnsmasq

install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"

on_chroot << EOF
systemctl enable dnsmasq
EOF

echo "[Stage X - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"
