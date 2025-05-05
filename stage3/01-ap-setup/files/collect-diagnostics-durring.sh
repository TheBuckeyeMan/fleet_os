#!/bin/bash
OUTPUT="/boot/firmware/diagnosis-during.txt"

{
  echo "=== [DURING] NetworkManager Status ==="
  nmcli device show wlan0

  echo -e "\n=== [DURING] Active Connections ==="
  nmcli connection show --active

  echo -e "\n=== [DURING] DNS Config ==="
  cat /etc/NetworkManager/dnsmasq.d/setup.conf 2>/dev/null || echo "No custom DNS config"

  echo -e "\n=== [DURING] Captive Portal Trigger ==="
  echo "GET /generate_204" | nc -w 3 10.42.0.1 80 || echo "Captive portal not responding"

  echo -e "\n=== [DURING] Listening Ports ==="
  sudo netstat -tulnp

  echo -e "\n=== [DURING] iptables NAT Rules ==="
  iptables -t nat -L -n -v

  echo -e "\n=== [DURING] Full iptables Dump ==="
  iptables-save

  echo -e "\n=== [DURING] DNS Masquerading Rules ==="
  iptables -t nat -L PREROUTING -n -v

  echo -e "\n=== [DURING] Flask Listening Check ==="
  curl -I http://10.42.0.1/generate_204 || echo "Flask not serving"


} | sudo tee "$OUTPUT" > /dev/null

echo "✅ DURING diagnostics written to $OUTPUT"