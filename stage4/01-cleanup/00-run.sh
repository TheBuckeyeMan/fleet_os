#!/bin/bash -e

install -m 755 files/pre-docker-cleanup.sh "${ROOTFS_DIR}/usr/local/bin/pre-docker-cleanup.sh"
install -m 644 files/pre-docker-cleanup.service "${ROOTFS_DIR}/etc/systemd/system/pre-docker-cleanup.service"

on_chroot << EOF
systemctl enable pre-docker-cleanup.service
EOF
