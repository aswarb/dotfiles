#!/bin/bash

# Get GPU clock speed
if command -v nvidia-smi >/dev/null 2>&1; then
    gpu_freq=$(nvidia-smi --query-gpu=clocks.current.graphics --format=csv,noheader,nounits 2>/dev/null)
    if [ -n "$gpu_freq" ]; then
        echo "$((gpu_freq / 1000))MHz"
    fi
elif command -v sensors >/dev/null 2>&1; then
    gpu_freq=$(sensors 2>/dev/null | grep 'sclk:' | awk '{print $2}' | head -1)
    if [ -n "$gpu_freq" ]; then
        echo "$gpu_freq"
    fi
fi

if [ -z "$gpu_freq" ]; then
    echo "N/A"
fi