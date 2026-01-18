#!/bin/bash

# Get average CPU frequency in GHz
freq=$(cat /proc/cpuinfo | grep "cpu MHz" | awk '{sum += $4} END {if (NR > 0) printf "%.2fGHz\n", sum / NR / 1000}')
if [ -z "$freq" ]; then
    echo "N/A"
else
    echo "$freq"
fi