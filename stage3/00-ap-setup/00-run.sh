#!/bin/bash -e

# Install dependencies
on_chroot << EOF
apt-get update
apt-get install -y hostapd dnsmasq python3-flask
EOF

# Configure hostapd to use custom config
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> "${ROOTFS_DIR}/etc/default/hostapd"

# Copy configs + scripts
install -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.conf"
install -m 755 files/setup-server.py "${ROOTFS_DIR}/usr/local/bin/setup-server.py"
install -m 644 files/ap-setup.service "${ROOTFS_DIR}/etc/systemd/system/ap-setup.service"
install -m 755 files/force-ap-mode.sh "${ROOTFS_DIR}/usr/local/bin/force-ap-mode.sh"
install -m 644 files/force-ap-mode.service "${ROOTFS_DIR}/etc/systemd/system/force-ap-mode.service"

# Unmask + enable system services AFTER files are copied
on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq
systemctl enable ap-setup.service
systemctl enable force-ap-mode.service
systemctl disable wpa_supplicant
EOF

# Auto-login for Pi user
install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
cat << EOF > "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM
EOF

# Force wlan0 name
sed -i 's/$/ net.ifnames=0/' "${ROOTFS_DIR}/boot/cmdline.txt"

# Disable wpa_supplicant so wlan0 stays free
on_chroot << EOF
systemctl disable wpa_supplicant
EOF

# Static IP for wlan0
echo -e "interface wlan0\n    static ip_address=192.168.4.1/24\n    nohook wpa_supplicant" >> "${ROOTFS_DIR}/etc/dhcpcd.conf"

