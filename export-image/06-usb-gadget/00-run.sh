#!/bin/bash -e

BOOT_DIR="${ROOTFS_DIR}/boot"
FIRMWARE_DIR="${ROOTFS_DIR}/boot/firmware"

# Enable SSH over USB (gadget mode)
if [ -f "${FIRMWARE_DIR}/config.txt" ]; then
  echo "dtoverlay=dwc2" >> "${FIRMWARE_DIR}/config.txt"
elif [ -f "${BOOT_DIR}/config.txt" ]; then
  echo "dtoverlay=dwc2" >> "${BOOT_DIR}/config.txt"
fi

# Append modules
echo "dwc2" >> "${ROOTFS_DIR}/etc/modules"
echo "g_ether" >> "${ROOTFS_DIR}/etc/modules"

# Enable USB ethernet gadget
if [ -f "${FIRMWARE_DIR}/cmdline.txt" ]; then
  sed -i 's/\(.*rootwait\)/\1 modules-load=dwc2,g_ether/' "${FIRMWARE_DIR}/cmdline.txt"
elif [ -f "${BOOT_DIR}/cmdline.txt" ]; then
  sed -i 's/\(.*rootwait\)/\1 modules-load=dwc2,g_ether/' "${BOOT_DIR}/cmdline.txt"
fi

# Enable SSH
touch "${FIRMWARE_DIR}/ssh" || touch "${BOOT_DIR}/ssh"
