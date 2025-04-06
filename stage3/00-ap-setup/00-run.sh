#!/bin/bash -e

# Install dependencies
on_chroot << EOF
apt-get update
apt-get install -y hostapd dnsmasq python3-flask
EOF

# Disable defaults so we use our configs
on_chroot << EOF
systemctl disable hostapd
systemctl disable dnsmasq
EOF

# Copy our config and scripts
install -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"
install -m 755 files/setup-server.py "${ROOTFS_DIR}/usr/local/bin/setup-server.py"
install -m 644 files/ap-setup.service "${ROOTFS_DIR}/etc/systemd/system/ap-setup.service"

#Make python file executable
chmod +x "${ROOTFS_DIR}/usr/local/bin/setup-server.py"

# Enable our custom AP + server service
on_chroot << EOF
systemctl enable ap-setup.service
EOF

# Enable auto-login for the pi user - Required for plug and play
install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
cat << EOF > "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM
EOF

