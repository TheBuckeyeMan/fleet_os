#!/bin/bash

PCAP_FILE="/boot/firmware/collect-diagnostics-live.pcap"
TXT_FILE="/boot/firmware/collect-diagnostics-live.txt"

echo "[INFO] Starting live traffic capture on wlan0..."
echo "[INFO] PCAP output: $PCAP_FILE"
echo "[INFO] Readable log output: $TXT_FILE"
echo "[INFO] Press Ctrl+C to stop both captures."

# Run two tcpdump commands in parallel:
# One writes raw packets (.pcap), one outputs full readable content (.txt)

# Raw PCAP (background)
tcpdump -i wlan0 -nn -s 0 -U -w "$PCAP_FILE" &
PCAP_PID=$!

# Human-readable output (foreground)
tcpdump -i wlan0 -nn -s 0 -U -l -A | tee "$TXT_FILE"

# On Ctrl+C, also stop background process
echo "[INFO] Stopping PCAP capture..."
kill $PCAP_PID
wait $PCAP_PID 2>/dev/null

echo "[INFO] All logs saved to:"
echo "       $PCAP_FILE"
echo "       $TXT_FILE"
