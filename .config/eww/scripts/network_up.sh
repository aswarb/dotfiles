#!/bin/bash

interface=$(ip route | grep default | awk '{print $5}' | head -1)

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
    tx_speed=$(( (tx_now - tx_prev) / (time_now - time_prev) / 1024 ))
else
    tx_speed=0
fi

echo "$rx_now $tx_now $time_now" > /tmp/eww_network

echo "↑ ${tx_speed}KB/s"