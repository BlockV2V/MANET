
# 🚀 Docker-Based MANET Testbed (with Custom DSR Routing)

This guide explains how to build an **emulated Mobile Ad Hoc Network (MANET)** on a single Linux laptop using:

* **Docker containers** (each acts as a MANET node)
* **`mac80211_hwsim`** (virtual Wi-Fi radios in the Linux kernel)
* **IBSS (ad-hoc) mode** for realistic L2 behavior
* A **custom DSR routing daemon with multi-metric Dijkstra** (research integration)

---

## 📋 1. Requirements

**Host machine**

* Ubuntu 22.04+ (or Debian-based Linux with kernel ≥ 5.x)
* `mac80211_hwsim` kernel module enabled

**Install dependencies:**

```bash
sudo apt update
sudo apt install -y docker.io docker-compose \
    iw iproute2 wireless-tools tcpdump iperf3 \
    git build-essential cmake util-linux
```

---

## 📡 2. Create Virtual Radios

Load the `hwsim` module with N radios (example: 5):

```bash
sudo modprobe mac80211_hwsim radios=5
```

Verify:

```bash
iw dev
```

You should see `wlan0, wlan1, wlan2 …` (one per virtual radio).


now set up into IBSS Mode

sudo ip link set wlan0 down
sudo iw dev wlan0 set type ibss
sudo ip link set wlan0 up


---

## 📂 3. Directory Structure

```plaintext
manet-docker/
├── docker-compose.yml
├── node.Dockerfile
├── scripts/
│   ├── node.sh
│   └── ocb-up.sh
└── configs/
    ├── nodeA.json
    ├── nodeB.json
    └── nodeC.json
```

---

## 🐳 4. Dockerfile (Node Definition)

`node.Dockerfile`

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    iproute2 iw wireless-tools tcpdump iperf3 net-tools iputils-ping \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
COPY scripts/ /root/scripts/
COPY configs/ /root/configs/

ENTRYPOINT ["/root/scripts/node.sh"]
```

---

## ⚙️ 5. Node Startup Script

`scripts/node.sh`

```bash
#!/bin/bash

NODE_ID=${NODE_ID:-nodeA}
CONFIG_FILE=/root/configs/${NODE_ID}.json

IPADDR=$(jq -r '.node.ip' $CONFIG_FILE)
IFACE=$(jq -r '.node.interface' $CONFIG_FILE)

/root/scripts/ocb-up.sh $IFACE $IPADDR

# Start routing daemon (replace with actual DSR implementation)
echo "Starting routing daemon for $NODE_ID with IP $IPADDR"
exec tail -f /dev/null
```

---

## 📡 6. IBSS Setup Script

`scripts/ocb-up.sh`

```bash
#!/bin/bash
IF=$1
IPADDR=$2
FREQ=2412   # 2.4GHz channel
BW=20MHZ

ip link set $IF down
iw dev $IF set type ibss
ip link set $IF up

# Join IBSS with SSID "manet-net"
iw dev $IF ibss join manet-net $FREQ $BW

ip addr flush dev $IF
ip addr add $IPADDR/24 dev $IF
```

---

## 📝 7. Config Files

Example `configs/nodeA.json`:

```json
{
  "node": {
    "id": "nodeA",
    "ip": "172.18.0.2",
    "interface": "wlan0"
  }
}
```

`configs/nodeB.json`:

```json
{
  "node": {
    "id": "nodeB",
    "ip": "172.18.0.3",
    "interface": "wlan0"
  }
}
```

---

## 🛠️ 8. docker-compose Setup

`docker-compose.yml`

```yaml
version: '3.9'

services:
  nodeA:
    build:
      context: .
      dockerfile: node.Dockerfile
    container_name: nodeA
    environment:
      - NODE_ID=nodeA
    network_mode: "none"
    privileged: true

  nodeB:
    build:
      context: .
      dockerfile: node.Dockerfile
    container_name: nodeB
    environment:
      - NODE_ID=nodeB
    network_mode: "none"
    privileged: true

  nodeC:
    build:
      context: .
      dockerfile: node.Dockerfile
    container_name: nodeC
    environment:
      - NODE_ID=nodeC
    network_mode: "none"
    privileged: true
```

---

## ▶️ 9. Running the Testbed

```bash
# Build images
docker-compose build

# Start nodes
docker-compose up -d

# Logs
docker logs nodeA
```

Test connectivity:

```bash
docker exec -it nodeA ping 172.18.0.3
docker exec -it nodeB iw dev wlan0 info
```

---

## 📡 10. Routing Daemon Integration

The **`dsr_daemon`** will run inside each container, managing routes.

### Example Config

`config.json`

```json
{
  "node": {
    "id": "nodeA",
    "ip": "172.18.0.2",
    "interface": "wlan0"
  },
  "protocol": {
    "name": "CustomDSR",
    "hello_interval_ms": 1000,
    "route_timeout_ms": 10000,
    "max_hop_count": 10
  },
  "metrics": {
    "weight_bandwidth": 0.5,
    "weight_latency": 0.3,
    "weight_energy": 0.2
  }
}
```

Run:

```bash
./dsr_daemon --config config.json
```

---

## 🧪 11. Monitoring & Debugging

* Capture packets:

```bash
docker exec -it nodeA tcpdump -i wlan0 -w nodeA.pcap
```

* Check peers:

```bash
docker exec -it nodeB iw dev wlan0 station dump
```

* Test throughput:

```bash
docker exec -it nodeA iperf3 -s
docker exec -it nodeB iperf3 -c 172.18.0.2
```

---

## 🔧 12. Manual IBSS Setup (Debugging)

If you want to bypass `docker-compose`, run manually:

```bash
docker run -it --net=none --name node1 ubuntu:22.04 bash
sudo ip link set wlan1 netns $(docker inspect -f '{{.State.Pid}}' node1)
```

Inside container:

```bashWould you like me to also add a scripts/setup_hwsim.sh helper script that automatically loads mac80211_hwsim and assigns wlanX devices to containers (so you don’t have to do it manually each time)?
apt update && apt install -y iproute2 iw
ip link set wlan1 up
iw dev wlan1 set type ibss
iw dev wlan1 ibss join test-mesh 2412 HT20
ip addr add 172.16.100.1/24 dev wlan1
```

Repeat for other nodes.

---

## 📚 13. Resources

* [Linux Wireless Wiki: mac80211\_hwsim](https://wireless.wiki.kernel.org/en/users/Drivers/mac80211_hwsim)
* [Docker Networking Docs](https://docs.docker.com/network/)
* [Mininet-WiFi](https://mininet-wifi.github.io/)
* [ArchWiki: Ad-hoc networking](https://wiki.archlinux.org/title/Ad-hoc_networking)
* **RFC 4728** – Dynamic Source Routing (DSR)
* **RFC 3561** – Ad hoc On-Demand Distance Vector (AODV)

YouTube:

* [mac80211\_hwsim tutorial](https://www.youtube.com/watch?v=Lp1nFxOaM9M)
* [Docker Networking Explained](https://www.youtube.com/watch?v=bKFMS5C4CG0)
* [Mininet-WiFi demo](https://www.youtube.com/watch?v=llWguQpoygA)

---

## ⚠️ Notes

* **Mobility**: Containers are static; emulate mobility with `tc netem` or Mininet-WiFi.
* **Persistence**: Radios disappear when `mac80211_hwsim` is removed; re-run `modprobe` if needed.
* **Future**: Switch from IBSS → OCB when real 802.11p hardware is available.

---
