#!/bin/bash -e
echo "[ap-setup - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

on_chroot << EOF
apt-get update
apt-get install -y python3-flask
apt-get install -y dhcpcd5=1:8.1.2-1+rpt2
apt-mark manual dhcpcd5
EOF

install -m 755 files/setup-server.py "${ROOTFS_DIR}/usr/local/bin/setup-server.py"
install -m 644 files/ap-setup.service "${ROOTFS_DIR}/etc/systemd/system/ap-setup.service"

on_chroot << EOF
systemctl enable ap-setup.service
EOF

echo "[ap-setup - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

