#!/bin/bash
OUTPUT="/boot/firmware/diagnosis-before.txt"

{

  echo "=== [BEFORE] INITIAL BOOT LOGS ==="
  journalctl -b

  echo "=== [BEFORE] NetworkManager Status ==="
  nmcli device show wlan0

  echo -e "\n=== [BEFORE] Active Connections ==="
  nmcli connection show --active

  echo -e "\n=== [BEFORE] DNS Config ==="
  cat /etc/NetworkManager/dnsmasq.d/setup.conf 2>/dev/null || echo "No custom DNS config"

  echo -e "\n=== [BEFORE] Captive Portal Trigger ==="
  echo "GET /generate_204" | nc -w 3 10.42.0.1 80 || echo "Captive portal not responding"

  echo -e "\n=== [BEFORE] Listening Ports ==="
  sudo netstat -tulnp

  echo -e "\n=== [BEFORE] set-iptables.service Status ==="
  systemctl status set-iptables.service

  echo -e "\n=== [BEFORE] set-iptables.service File ==="
  cat /etc/systemd/system/set-iptables.service 2>/dev/null || echo "Service file missing"

  echo -e "\n=== [BEFORE] iptables-rules.sh Contents ==="
  cat /usr/local/bin/iptables-rules.sh 2>/dev/null || echo "Script not found"

  echo -e "\n=== [BEFORE] systemd Services ==="
  systemctl list-units --failed

  echo -e "\n=== [BEFORE] IP Tables Rules (NAT) ==="
  iptables -t nat -L -n -v

  echo -e "\n=== [BEFORE] DNSMasq Override Test ==="
  nslookup captive.apple.com 10.42.0.1 || dig captive.apple.com @10.42.0.1

  echo -e "\n=== [BEFORE] DNS: Test captive.apple.com locally ==="
  dig +short captive.apple.com @127.0.0.1

  echo -e "\n=== [BEFORE] DNSMasq Status ==="
  ps aux | grep dnsmasq

} | sudo tee "$OUTPUT" > /dev/null

echo "✅ BEFORE diagnostics written to $OUTPUT"