#!/bin/bash
# Check if the system has an NVIDIA GPU
if lspci | grep -i "nvidia" >/dev/null 2>&1; then
    # If nvidia-smi is available, get GPU usage from it
    if command -v nvidia-smi >/dev/null 2>&1; then
        gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
        if [ -n "$gpu_usage" ]; then
            echo "${gpu_usage}%"
        fi
    fi
else
    # If no NVIDIA GPU detected, attempt to get GPU usage from other sources (e.g., AMD, Intel)
    # Check if /sys/class/drm/card1/device/gpu_busy_percent exists (common for AMD/Intel)
    if [ -f /sys/class/drm/card1/device/gpu_busy_percent ]; then
        gpu_usage=$(cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null)
        if [ -n "$gpu_usage" ]; then
            echo "${gpu_usage}%"
        fi
    # Fallback to sensors for general GPU info (useful for AMD/Intel)
    elif command -v sensors >/dev/null 2>&1; then
        gpu_usage=$(sensors 2>/dev/null | grep -i 'gpu' | awk '{print $2}' | head -1)
        if [ -n "$gpu_usage" ]; then
            echo "$gpu_usage"
        fi
    fi
fi

# If no GPU usage detected
if [ -z "$gpu_usage" ]; then
    echo "N/A"
fi

