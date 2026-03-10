#!/bin/bash

# Prefer hwmon k10temp (AMD CPUs) first for reliability
HWMON_CPU_TEMP="/sys/class/hwmon/hwmon4/temp1_input"
THERMAL_ZONE="/sys/class/thermal/thermal_zone0/temp"

if [ -f "$HWMON_CPU_TEMP" ]; then
    temp=$(awk '{printf "%.1f", $1/1000}' "$HWMON_CPU_TEMP")
    echo "${temp}°C"
    exit 0
fi

if [ -f "$THERMAL_ZONE" ]; then
    temp=$(awk '{printf "%.1f", $1/1000}' "$THERMAL_ZONE")
    echo "${temp}°C"
    exit 0
fi

if command -v sensors >/dev/null 2>&1; then
    cpu_line=$(sensors | grep -m1 -E 'Tctl:|Core 0:')
    if [ ! -z "$cpu_line" ]; then
        temp=$(echo "$cpu_line" | grep -oP '\+?\d+\.\d+' | head -1)
        if [ ! -z "$temp" ]; then
            echo "${temp}°C"
            exit 0
        fi
    fi
fi

echo "N/A"
