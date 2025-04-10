#!/bin/bash -e

# Wait for wlan0 to actually exist
COUNTER=0
while ! ip link show wlan0 &>/dev/null; do
  echo "[force-ap-mode] Waiting for wlan0 to exist..."
  sleep 1
  COUNTER=$((COUNTER + 1))
  if [ $COUNTER -ge 30 ]; then
    echo "[force-ap-mode] wlan0 not found after 30s, exiting."
    exit 1
  fi
done

# Force AP mode clean
ip link set wlan0 down || true
iw dev wlan0 set type __ap || true
ip link set wlan0 up || true

echo "[force-ap-mode] wlan0 is ready in AP mode."
