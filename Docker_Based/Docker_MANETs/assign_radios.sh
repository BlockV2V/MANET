#!/bin/bash
set -e

# Make sure radios exist
sudo modprobe mac80211_hwsim radios=5

for i in {0..4}; do
  CNAME="node$((i+1))"
  IFACE="wlan$i"
  PID=$(docker inspect -f '{{.State.Pid}}' $CNAME)

  echo "Assigning $IFACE → $CNAME"
  sudo ip link set $IFACE netns $PID
done
