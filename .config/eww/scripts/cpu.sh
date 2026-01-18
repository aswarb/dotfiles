#!/bin/bash

# Get CPU usage percentage
cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/")
cpu_usage=$(echo "100 - $cpu_idle" | bc)
echo "${cpu_usage}%"