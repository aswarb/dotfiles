#!/bin/bash

# Get CPU temperature in °C
temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1 / 1000}')
if [ -z "$temp" ]; then
    echo "N/A"
else
    echo "${temp}°C"
fi