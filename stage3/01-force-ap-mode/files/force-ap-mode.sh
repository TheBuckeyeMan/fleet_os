#!/bin/bash -e

echo "[force-ap-mode] Starting force-ap-mode.sh" >> /boot/firmware/build-stage-logs.txt

# Unblock wlan0 just in case RF-kill is active
rfkill unblock wifi || true
rfkill unblock all || true

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

# Force AP Mode clean
ip link set wlan0 down || true
iw dev wlan0 set type __ap || true
ip link set wlan0 up || true

echo "[force-ap-mode] wlan0 is ready in AP mode."

echo "[force-ap-mode] wlan0 is ready in AP mode." >> /boot/firmware/build-stage-logs.txt