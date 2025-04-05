#!/bin/bash -e

# Enable SSH over USB (gadget mode)
echo "dtoverlay=dwc2" >> "${ROOTFS_DIR}/boot/config.txt"

# Append modules to /etc/modules
echo "dwc2" >> "${ROOTFS_DIR}/etc/modules"
echo "g_ether" >> "${ROOTFS_DIR}/etc/modules"

# Enable USB ethernet gadget
sed -i 's/\(.*rootwait\)/\1 modules-load=dwc2,g_ether/' "${ROOTFS_DIR}/boot/cmdline.txt"

# Create empty ssh file to auto-enable SSH
touch "${ROOTFS_DIR}/boot/ssh"
