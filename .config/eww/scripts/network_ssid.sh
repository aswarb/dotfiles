#!/bin/bash

ssid=$(iwgetid -r 2>/dev/null || echo "Ethernet")
echo "$ssid"