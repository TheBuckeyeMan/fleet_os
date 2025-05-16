#!/bin/bash

log() {
    logger -t install-pi-tools "$1"
}

log "[ OK ] Begining to Install PI Tools"

#Script to check if the wifi is up and running 
for i in {1..10}; do
    if ping -c 1 8.8.8.8 &> /dev/null; then
        log "[ OK ] Device Connected to Internet"
        break
    else 
        log "[ WARN ] Device is not connected to the Internet. Retrying in 5 seconds..."
    fi
    
    log "[ INFO ] Not connected yet (attempt $i/10)..."
    sleep 5
done

#Do one final validation
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    log "[ ERROR ] Device is not connected to the Internet. Docker wand other required tools will not be installed..."
    exit 0
fi

# Install or update Docker
if ! command -v docker &> /dev/null; then
    log "[ INFO ] Docker not installed. Installing Docker..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh 2>&1 | logger -t docker-setup
    log "[ OK ] DOcker has been Installed!"
else
    log "[ INFO ] Docker already installed. Updating Docker..."
    apt-get update && apt-get install --only-upgrade docker-ce docker-ce-cli containerd.io -y 2>&1 | logger -t docker-setup
    log "[ OK ] Docker has been updated successfully!"
fi

log '[ INFO ] Pi Tools has been successfully Installed"
