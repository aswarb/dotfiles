#!/bin/bash

# Get memory details with 2 decimal places
mem_info=$(free | awk 'NR==2{printf "%.2fG/%.2fG | C %.2fG | F %.2fG", $3/1024/1024, $7/1024/1024, $6/1024/1024, $4/1024/1024}')
echo "$mem_info"
