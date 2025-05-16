#!/bin/bash -e

install -m 755 files/post-wifi-update.sh "${ROOTFS_DIR}/usr/local/bin/post-wifi-update.sh"
install -m 644 files/post-wifi-update.service "${ROOTFS_DIR}/etc/systemd/system/post-wifi-update.service"

on_chroot << EOF
systemctl enable post-wifi-update.service
EOF