#!/bin/bash

# Check for an NVIDIA GPU using lspci (without assuming nvidia-smi is available)
if lspci | grep -i "nvidia" >/dev/null 2>&1; then
    # Check if nvidia-smi is available
    if command -v nvidia-smi >/dev/null 2>&1; then
        gpu_freq=$(nvidia-smi --query-gpu=clocks.current.graphics --format=csv,noheader,nounits 2>/dev/null)
        if [ -n "$gpu_freq" ]; then
            echo "$((gpu_freq / 1000)) MHz"
        fi
    fi
else
    # No NVIDIA GPU detected, check other sensors (e.g., AMD, Intel, or general GPU)
    if command -v sensors >/dev/null 2>&1; then
        gpu_freq=$(sensors 2>/dev/null | grep 'sclk:' | awk '{print $2}' | head -1)
        if [ -n "$gpu_freq" ]; then
            echo "$gpu_freq"
        fi
    fi
fi

# If no GPU frequency detected
if [ -z "$gpu_freq" ]; then
    echo "N/A"
fi

