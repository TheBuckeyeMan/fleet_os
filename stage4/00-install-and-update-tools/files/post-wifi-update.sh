#!/bin/bash

LOGFILE="/var/log/post-wifi-update.log"
echo "[$(date)] Starting post-wifi-update..." >> "$LOGFILE"

# Wait until internet is actually reachable
for i in {1..10}; do
    if ping -c 1 8.8.8.8 &>/dev/null; then
        echo "Internet available." >> "$LOGFILE"
        break
    fi
    echo "Waiting for internet..." >> "$LOGFILE"
    sleep 5
done

# If still no connection, exit
if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "No internet. Skipping updates." >> "$LOGFILE"
    exit 1
fi

# Update package lists
apt-get update >> "$LOGFILE" 2>&1

# Docker check and install/update
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing..." >> "$LOGFILE"
    curl -fsSL https://get.docker.com | sh >> "$LOGFILE" 2>&1
else
    echo "Docker found. Updating if needed..." >> "$LOGFILE"
    apt-get install --only-upgrade -y docker-ce >> "$LOGFILE" 2>&1 || echo "Docker not upgraded or already latest" >> "$LOGFILE"
fi

# Install or update nmap-ncat
if ! command -v ncat &> /dev/null; then
    echo "Installing nmap-ncat..." >> "$LOGFILE"
    apt-get install -y nmap >> "$LOGFILE" 2>&1
else
    echo "nmap-ncat found. Updating..." >> "$LOGFILE"
    apt-get install --only-upgrade -y nmap >> "$LOGFILE" 2>&1
fi

echo "[$(date)] Tool install/update complete." >> "$LOGFILE"