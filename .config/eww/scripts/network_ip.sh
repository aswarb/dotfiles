#!/bin/bash

ip_info=$(ip -4 addr show wlan0 | awk '/inet / {print $2}')
echo "$ip_info"
