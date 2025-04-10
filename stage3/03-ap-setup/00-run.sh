#!/bin/bash -e

echo "[Stage X - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

apt-get install -y python3-flask

install -m 755 files/setup-server.py "${ROOTFS_DIR}/usr/local/bin/setup-server.py"
install -m 644 files/ap-setup.service "${ROOTFS_DIR}/etc/systemd/system/ap-setup.service"

on_chroot << EOF
systemctl enable ap-setup.service
EOF

echo "[Stage X - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"
