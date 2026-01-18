#!/bin/bash

# Get network info

# Get IP and mask
ip_info=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}')

# Get SSID
ssid=$(iwgetid -r 2>/dev/null || echo "Ethernet")

# Get interface
interface=$(ip route | grep default | awk '{print $5}' | head -1)

# Get speeds (simplified, requires storing previous values)
if [ -f /tmp/eww_network ]; then
    prev=$(cat /tmp/eww_network)
    rx_prev=$(echo $prev | cut -d' ' -f1)
    tx_prev=$(echo $prev | cut -d' ' -f2)
    time_prev=$(echo $prev | cut -d' ' -f3)
else
    rx_prev=0
    tx_prev=0
    time_prev=$(date +%s)
fi

rx_now=$(cat /proc/net/dev | grep $interface | awk '{print $2}')
tx_now=$(cat /proc/net/dev | grep $interface | awk '{print $10}')
time_now=$(date +%s)

if [ $time_prev -ne $time_now ]; then
    rx_speed=$(( (rx_now - rx_prev) / (time_now - time_prev) / 1024 ))
    tx_speed=$(( (tx_now - tx_prev) / (time_now - time_prev) / 1024 ))
    up_down="↑ ${tx_speed}KB/s | ↓ ${rx_speed}KB/s"
else
    up_down="↑ 0KB/s | ↓ 0KB/s"
fi

echo "$rx_now $tx_now $time_now" > /tmp/eww_network

echo "IP: $ip_info @ $ssid | $up_down"