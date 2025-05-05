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

  echo "=== [AFTER]] FINAL BOOT LOGS ==="
  journalctl -b

} | sudo tee "$OUTPUT" > /dev/null

echo "✅ AFTER diagnostics written to $OUTPUT"
