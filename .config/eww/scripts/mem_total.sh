#!/bin/bash

total=$(free | awk 'NR==2{printf "%.1f", $2/1024/1024}')
echo "${total}G"