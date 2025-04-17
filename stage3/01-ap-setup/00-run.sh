#!/bin/bash -e

echo "[Stage 3 - 01-ap-setup - START] $(date)" >> /boot/firmware/build-stage-logs.txt

on_chroot << EOF
apt-get update
apt-get install -y python3-flask
EOF

# Copy python server and service
install -m 755 files/setup-server.py "$ROOTFS_DIR/usr/local/bin/setup-server.py"
install -m 644 files/ap-setup.service "$ROOTFS_DIR/etc/systemd/system/ap-setup.service"

# Enable the service
on_chroot << EOF
systemctl enable ap-setup.service
EOF

echo "[Stage 3 - 01-ap-setup - END] $(date)" >> /boot/firmware/build-stage-logs.txt
