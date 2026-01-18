#!/bin/bash

used=$(free | awk 'NR==2{printf "%.1f", $3/1024/1024}')
echo "${used}G"