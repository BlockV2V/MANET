# Docker & Docker-Compose Setup for MANET Emulation

This guide explains how to build a **multi-node MANET testbed** using **Docker** and **docker-compose**. Each container acts as a MANET node, running in **IBSS (ad-hoc)** mode with virtual radios (`mac80211_hwsim`).

---

## 1. Requirements

* **Ubuntu 22.04+** (host machine)
* Docker ≥ 20.10
* docker-compose ≥ 1.29
* Linux kernel with `mac80211_hwsim`

Install basics:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose iw iproute2 wireless-tools tcpdump iperf3
```

Load virtual Wi-Fi radios:

```bash
sudo modprobe mac80211_hwsim radios=5
```

Verify:

```bash
iw dev
```

---

## 2. Directory Structure

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

## 3. Dockerfile (Node Definition)

`node.Dockerfile`

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    iproute2 iw wireless-tools tcpdump iperf3 net-tools iputils-ping \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
COPY scripts/ /root/scripts/
COPY configs/ /root/configs/

ENTRYPOINT ["/root/scripts/node.sh"]
```

---

## 4. Node Startup Script

`scripts/node.sh`

```bash
#!/bin/bash

NODE_ID=${NODE_ID:-nodeA}
CONFIG_FILE=/root/configs/${NODE_ID}.json

IPADDR=$(jq -r '.node.ip' $CONFIG_FILE)
IFACE=$(jq -r '.node.interface' $CONFIG_FILE)

# Configure ad-hoc interface
/root/scripts/ocb-up.sh $IFACE $IPADDR

# Start routing daemon (placeholder for custom DSR)
echo "Starting routing daemon for $NODE_ID with IP $IPADDR"
exec tail -f /dev/null  # keep container alive
```

Make executable:

```bash
chmod +x scripts/*.sh
```

---

## 5. OCB/IBSS Setup Script

`scripts/ocb-up.sh`

```bash
#!/bin/bash
IF=$1
IPADDR=$2
FREQ=2412   # IBSS freq in MHz
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

## 6. Config Files

`configs/nodeA.json`

```json
{
  "node": {
    "id": "nodeA",
    "ip": "172.18.0.2",
    "interface": "wlan0"
  }
}
```

`configs/nodeB.json`

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

## 7. docker-compose.yml

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

## 8. Running the Testbed

```bash
# Build all images
docker-compose build

# Start containers
docker-compose up -d

# View logs
docker logs nodeA
```

Verify:

```bash
docker exec -it nodeA iw dev wlan0 info
docker exec -it nodeB ping 172.18.0.2
```

---

## 9. Monitoring

* Capture traffic:

```bash
docker exec -it nodeA tcpdump -i wlan0 -w nodeA.pcap
```

* Test throughput:

```bash
docker exec -it nodeA iperf3 -s
docker exec -it nodeB iperf3 -c 172.18.0.2
```

---

## 10. Notes

* **Mobility**: Containers are static; mobility can be emulated by dynamically changing IPs or routes in scripts.
* **Scalability**: `docker-compose` can scale to N nodes easily.
* **Routing Daemon**: Replace `tail -f /dev/null` in `node.sh` with your **custom DSR implementation**.

---

✅ This setup gives you a **reproducible, multi-node MANET testbed inside Docker**, using docker-compose to orchestrate IBSS/OCB-mode nodes.
