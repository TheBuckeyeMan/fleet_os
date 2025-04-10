#!/bin/bash -e
ip link set wlan0 down
iw dev wlan0 set type __ap
ip link set wlan0 up
