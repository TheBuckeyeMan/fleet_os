#!/bin/bash -e

# Log build start
mkdir -p "${ROOTFS_DIR}/boot/firmware"
echo "[Stage 01-ap-setup - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

# Install Flask
on_chroot << EOF
apt-get update
apt-get install -y python3-flask
EOF

# Copy Flask server and systemd service
install -m 755 files/setup-server.py "${ROOTFS_DIR}/usr/local/bin/"
install -m 644 files/ap-setup.service "${ROOTFS_DIR}/etc/systemd/system/"

# Enable the Flask systemd service
on_chroot << EOF
systemctl enable ap-setup.service
EOF

# Copy static NetworkManager AP profile
install -D -m 600 files/ap-mode.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/ap-mode.nmconnection"

# Ensure proper permissions and reload connection
on_chroot << EOF
chmod 600 /etc/NetworkManager/system-connections/ap-mode.nmconnection
EOF


# Force NetworkManager to use internal dnsmasq for AP DNS
install -d "${ROOTFS_DIR}/etc/NetworkManager/conf.d"
echo -e "[main]\ndns=dnsmasq" > "${ROOTFS_DIR}/etc/NetworkManager/conf.d/dns.conf"

# Ensure DNS hijack works (NetworkManager internal dnsmasq)
install -d "${ROOTFS_DIR}/etc/NetworkManager/dnsmasq.d"
install -m 644 files/setup.conf "${ROOTFS_DIR}/etc/NetworkManager/dnsmasq.d/setup.conf"

install -d "${ROOTFS_DIR}/etc/NetworkManager/conf.d"
echo -e "[main]\ndns=dnsmasq" > "${ROOTFS_DIR}/etc/NetworkManager/conf.d/use-dnsmasq.conf"

# Log build end
echo "[Stage 01-ap-setup - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"