#!/bin/bash -e

echo "[${0}] START --- $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

# Enable auto-login for the pi user
install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"

cat << EOF > "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM
EOF

echo "[${0}] END --- $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"
