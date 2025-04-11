#!/bin/bash -e
echo "[force-ap-mode - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

install -m 755 files/force-ap-mode.sh "${ROOTFS_DIR}/usr/local/bin/force-ap-mode.sh"
install -m 644 files/force-ap-mode.service "${ROOTFS_DIR}/etc/systemd/system/force-ap-mode.service"

on_chroot << EOF
systemctl enable force-ap-mode.service
EOF

echo "[force-ap-mode - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

