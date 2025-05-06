#!/bin/bash -e

# Log build start
mkdir -p "${ROOTFS_DIR}/boot/firmware"
echo "[Stage 01-ap-setup - START] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

#Add custom debug command
install -m 755 files/collect-diagnostics-before.sh "${ROOTFS_DIR}/usr/local/bin/collect-diagnostics-before"
install -m 755 files/collect-diagnostics-durring.sh "${ROOTFS_DIR}/usr/local/bin/collect-diagnostics-durring"
install -m 755 files/collect-diagnostics-live.sh "${ROOTFS_DIR}/usr/local/bin/collect-diagnostics-live.sh"
install -m 755 files/collect-diagnostics-after.sh "${ROOTFS_DIR}/usr/local/bin/collect-diagnostics-after"

# Install Flask
on_chroot << EOF
apt-get update
apt-get install -y python3-flask
apt-get install -y iptables
apt-get install -y dnsutils
apt-get install -y tcpdump
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
sed -i '/^\[main\]/a dns=dnsmasq' "${ROOTFS_DIR}/etc/NetworkManager/NetworkManager.conf"

# echo -e "[main]\ndns=dnsmasq" > "${ROOTFS_DIR}/etc/NetworkManager/conf.d/dns.conf"

# Ensure DNS hijack works (NetworkManager internal dnsmasq)
install -d "${ROOTFS_DIR}/etc/NetworkManager/dnsmasq.d"
install -m 644 files/setup.conf "${ROOTFS_DIR}/etc/NetworkManager/dnsmasq.d/setup.conf"

# install -d "${ROOTFS_DIR}/etc/NetworkManager/conf.d"
# echo -e "[main]\ndns=dnsmasq" > "${ROOTFS_DIR}/etc/NetworkManager/conf.d/use-dnsmasq.conf"

echo "[Captive Portal - iptables NAT rules] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"

# Install systemd unit and script
install -m 644 files/set-iptables.service "${ROOTFS_DIR}/etc/systemd/system/set-iptables.service"
install -m 755 files/iptables-rules.sh "${ROOTFS_DIR}/usr/local/bin/iptables-rules.sh"

on_chroot << EOF
systemctl enable set-iptables.service
EOF


# Log build end
echo "[Stage 01-ap-setup - END] $(date)" >> "${ROOTFS_DIR}/boot/firmware/build-stage-logs.txt"