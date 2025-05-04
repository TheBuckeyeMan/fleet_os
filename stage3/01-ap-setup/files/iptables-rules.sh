#!/bin/bash

# Redirect all DNS to 10.42.0.1 (Pi's AP address)
iptables -t nat -A PREROUTING -i wlan0 -p udp --dport 53 -j DNAT --to-destination 10.42.0.1:53
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 53 -j DNAT --to-destination 10.42.0.1:53

# Redirect all HTTP to the Flask app (on port 80)
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j DNAT --to-destination 10.42.0.1:80

# Save iptables rules if needed (optional)
# iptables-save > /etc/iptables/rules.v4
