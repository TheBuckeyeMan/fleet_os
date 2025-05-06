#!/bin/bash
OUTPUT="/boot/firmware/diagnosis-after.txt"

{
  echo "=== [AFTER] WiFi Status ==="
  nmcli device show wlan0

  echo -e "\n=== [AFTER] Active Connections ==="
  nmcli connection show --active

  echo -e "\n=== [AFTER] Process List ==="
  ps aux | grep -E "flask|dnsmasq|reboot|nmcli"

  echo -e "\n=== [AFTER] Network Routes ==="
  ip route

  echo -e "\n=== [AFTER] Captive Portal Status ==="
  echo "GET /generate_204" | nc -w 3 10.42.0.1 80 || echo "Portal dead or WiFi changed"

  echo -e "\n=== [AFTER] DNS and HTTP NAT Status ==="
  iptables -t nat -L PREROUTING -n -v

  echo -e "\n=== [AFTER] flask Process and Listening Port ==="
  ps aux | grep flask
  netstat -tulnp | grep :80

  echo -e "\n=== [AFTER] DNSMasq Leases ==="
  sudo cat /var/lib/misc/dnsmasq.leases 2>/dev/null || echo "No leases file"

  echo -e "\n=== [AFTER] DNSMasq Lease File ==="
  cat /var/lib/misc/dnsmasq.leases 2>/dev/null || echo "No leases"

  echo -e "\n=== [AFTER] DNS: External hijack test ==="
  dig google.com @10.42.0.1

  echo "=== [AFTER]] FINAL BOOT LOGS ==="
  journalctl -b

} | sudo tee "$OUTPUT" > /dev/null

echo "✅ AFTER diagnostics written to $OUTPUT"
