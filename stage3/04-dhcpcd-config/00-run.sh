#!/bin/bash -e

echo "[Stage 04-dhcpcd-config - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

# Ensure directory
install -d "${ROOTFS_DIR}/etc"

# Copy dhcpcd config
install -m 644 files/dhcpcd.conf "${ROOTFS_DIR}/etc/dhcpcd.conf"



echo "[Stage 04-dhcpcd-config - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"
