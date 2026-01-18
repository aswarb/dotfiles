#!/bin/bash

cached=$(free | awk 'NR==2{printf "%.1f", $6/1024/1024}')
echo "${cached}G"