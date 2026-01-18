#!/bin/bash

free_mem=$(free | awk 'NR==2{printf "%.1f", $4/1024/1024}')
echo "${free_mem}G"