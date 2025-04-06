#!/bin/bash -e

# Ensure the boot directories exist
mkdir -p "${ROOTFS_DIR}/boot"
mkdir -p "${ROOTFS_DIR}/boot/firmware"
mkdir -p "${ROOTFS_DIR}/etc"

# Enable SSH over USB (gadget mode)
if [ -f "${ROOTFS_DIR}/boot/firmware/config.txt" ]; then
  echo "dtoverlay=dwc2" >> "${ROOTFS_DIR}/boot/firmware/config.txt"
elif [ -f "${ROOTFS_DIR}/boot/config.txt" ]; then
  echo "dtoverlay=dwc2" >> "${ROOTFS_DIR}/boot/config.txt"
fi

# Append modules
echo "dwc2" >> "${ROOTFS_DIR}/etc/modules"
echo "g_ether" >> "${ROOTFS_DIR}/etc/modules"

# Enable USB ethernet gadget
if [ -f "${ROOTFS_DIR}/boot/firmware/cmdline.txt" ]; then
  sed -i 's/\(.*rootwait\)/\1 modules-load=dwc2,g_ether/' "${ROOTFS_DIR}/boot/firmware/cmdline.txt"
elif [ -f "${ROOTFS_DIR}/boot/cmdline.txt" ]; then
  sed -i 's/\(.*rootwait\)/\1 modules-load=dwc2,g_ether/' "${ROOTFS_DIR}/boot/cmdline.txt"
fi

# Enable SSH — only touch it if the correct directory exists
if [ -d "${ROOTFS_DIR}/boot/firmware" ]; then
  touch "${ROOTFS_DIR}/boot/firmware/ssh"
elif [ -d "${ROOTFS_DIR}/boot" ]; then
  touch "${ROOTFS_DIR}/boot/ssh"
fi
