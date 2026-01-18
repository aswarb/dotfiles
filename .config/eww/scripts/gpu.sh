#!/bin/bash

# Get GPU usage percentage
if command -v nvidia-smi >/dev/null 2>&1; then
    gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
else
    gpu_usage=$(cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null)
fi

if [ -z "$gpu_usage" ]; then
    echo "N/A"
else
    echo "${gpu_usage}%"
fi