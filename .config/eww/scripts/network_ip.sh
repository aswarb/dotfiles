#!/bin/bash

ip_info=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}')
echo "$ip_info"