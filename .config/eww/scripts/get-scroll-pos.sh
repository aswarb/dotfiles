#!/bin/bash
while true; do
  for i in {0..100..1}; do
    eww update scroll-x="-${i}%"
    sleep 0.1
  done
  sleep 1
  for i in {100..0..1}; do
    eww update scroll-x="-${i}%"
    sleep 0.1
  done
  sleep 10
done
