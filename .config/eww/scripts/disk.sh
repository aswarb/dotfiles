#!/bin/bash

# Get disk usage percentage for root
disk_usage=$(df / | tail -1 | awk '{print $5}')
echo "$disk_usage"