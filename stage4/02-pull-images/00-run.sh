#!/bin/bash -e

install -m 755 files/pull-images.sh "${ROOTFS_DIR}/usr/local/bin/pull-images.sh"
install -m 644 files/pull-images.service "${ROOTFS_DIR}/etc/systemd/system/pull-images.service"

on_chroot << EOF
systemctl enable pull-images.service
EOF