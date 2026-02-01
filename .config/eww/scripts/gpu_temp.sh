#!/bin/bash
# Check if the system has an NVIDIA GPU
if lspci | grep -i "nvidia" >/dev/null 2>&1; then
    # If nvidia-smi is available, get GPU temperature
    if command -v nvidia-smi >/dev/null 2>&1; then
        gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
        if [ -n "$gpu_temp" ]; then
            echo "${gpu_temp}°C"
        fi
    fi
else
    # If no NVIDIA GPU detected, attempt to get GPU temperature from other sources (e.g., AMD, Intel)
    # Check if sensors can provide temperature (common for AMD/Intel)
    if command -v sensors >/dev/null 2>&1; then
        gpu_temp=$(sensors 2>/dev/null | grep 'edge:' | awk '{print $2}' | sed 's/+//' | sed 's/°C//')
        if [ -n "$gpu_temp" ]; then
            echo "${gpu_temp}°C"
        fi
    fi
fi

# If no GPU temperature detected
if [ -z "$gpu_temp" ]; then
    echo "N/A"
fi

