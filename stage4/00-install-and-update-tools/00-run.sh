#!/bin/bash -e

echo "[Stage 04 - Install/Update Tools START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

# Install the script and systemd unit
install -m 755 files/post-wifi-update.sh "${ROOTFS_DIR}/usr/local/bin/post-wifi-update.sh"
install -m 644 files/post-wifi-update.service "${ROOTFS_DIR}/etc/systemd/system/post-wifi-update.service"

# Enable the service
on_chroot << EOF
systemctl enable post-wifi-update.service
EOF

echo "[Stage 04 - Install/Update Tools END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"