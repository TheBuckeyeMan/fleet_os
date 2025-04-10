#!/bin/bash -e

# Enable auto-login for the pi user
install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"

cat << EOF > "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM
EOF
