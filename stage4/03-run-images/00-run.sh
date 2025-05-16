#!/bin/bash -e

install -m 755 files/run-images.sh "${ROOTFS_DIR}/usr/local/bin/run-images.sh"
install -m 644 files/run-images.service "${ROOTFS_DIR}/etc/systemd/system/run-images.service"

on_chroot << EOF
systemctl enable run-images.service
EOF