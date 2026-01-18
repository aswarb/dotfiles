#!/bin/bash

# Get GPU temperature
if command -v nvidia-smi >/dev/null 2>&1; then
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
elif command -v sensors >/dev/null 2>&1; then
    gpu_temp=$(sensors 2>/dev/null | grep 'edge:' | awk '{print $2}' | sed 's/+//' | sed 's/°C//')
else
    gpu_temp=""
fi

if [ -z "$gpu_temp" ]; then
    echo "N/A"
else
    echo "${gpu_temp}°C"
fi