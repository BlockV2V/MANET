Great — let’s make a **single structured `.md` document** that combines:

* Testbed setup instructions (from `README.txt`)
* `config.json` skeleton
* CLI spec
* Protocol behavior
* Future developer notes

This way your team has a **professional-grade project manual**. I’ll call it `MANET_TESTBED_GUIDE.md`.

---

````markdown
# MANET Testbed Guide – Custom DSR + Multi-Metric Dijkstra

This document describes how to set up a **physical MANET testbed on Linux laptops**
using **IEEE 802.11 OCB mode (802.11p)** and how to integrate a **custom DSR routing
protocol** enhanced with a **multi-metric Dijkstra algorithm**.

The guide is organized as follows:
1. Requirements
2. Network Interface Setup
3. IP Addressing & Topology
4. Helper Script
5. Routing Daemon Specification
6. `config.json` Skeleton
7. CLI Interface
8. Protocol Behavior
9. Deployment Workflow
10. Debugging & Monitoring
11. Developer Notes

---

## 1. Requirements

**Hardware**
- Linux laptops (Ubuntu 22.04 LTS recommended)
- Wi-Fi chipsets supporting OCB mode (e.g., Atheros ath9k/ath10k, some mt76)
- Optional: GPS dongle if geo-coordinates are used in routing

**Software**
```bash
sudo apt update
sudo apt install -y iw iproute2 wireless-tools tcpdump iperf3 git build-essential cmake
````

Optional:

* `chrony` or `ntp` for clock sync
* `ansible` for multi-node deployment

---

## 2. Network Interface Setup (OCB Mode)

Replace `wlan0` with your NIC name.

```bash
sudo ip link set wlan0 down
sudo iw dev wlan0 set type ocb
sudo ip link set wlan0 up
sudo iw dev wlan0 ocb join 5890 10MHZ
sudo ip addr add 172.16.100.X/24 dev wlan0
```

Verify:

```bash
iw dev wlan0 info
iw dev wlan0 ocb show
ip -s link show wlan0
```

---

## 3. IP Addressing & Topology

Assign static IPs:

* Node A → `172.16.100.1`
* Node B → `172.16.100.2`
* Node C → `172.16.100.3`

Routing will be managed by the custom daemon.

---

## 4. Helper Script – `ocb-up.sh`

Place in `/usr/local/sbin/ocb-up.sh`.

```bash
#!/bin/bash
IF=wlan0
IPADDR=$1
FREQ=5890
BW=10MHZ

sudo iw reg set DE              # Adjust regulatory domain
sudo ip link set $IF down
sudo iw dev $IF set type ocb
sudo ip link set $IF up
sudo iw dev $IF ocb join $FREQ $BW
sudo ip addr flush dev $IF
sudo ip addr add $IPADDR/24 dev $IF
```

Usage:

```bash
sudo /usr/local/sbin/ocb-up.sh 172.16.100.10
```

---

## 5. Routing Daemon Specification

The **routing daemon** (`dsr_daemon`) will:

* Bind to the wireless OCB interface
* Exchange DSR control messages:

  * RREQ (Route Request)
  * RREP (Route Reply)
  * RERR (Route Error)
* Use **multi-metric Dijkstra** for route selection
* Maintain a route cache with timeout policies
* Log state and routing decisions

---

## 6. `config.json` Skeleton

```json
{
  "node": {
    "id": "nodeA",
    "ip": "172.16.100.1",
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
  },

  "logging": {
    "level": "debug",
    "file": "/var/log/dsr_daemon.log"
  }
}
```

---

## 7. CLI Interface

Base command:

```bash
./dsr_daemon --config config.json
```

Optional arguments:

```bash
  --interface wlan0         # network interface
  --ip 172.16.100.1         # local IP
  --id nodeA                # logical node identifier
  --log-level info          # runtime logging
  --dump-routes routes.txt  # periodic route dump
```

---

## 8. Protocol Behavior

**Packet header structure (suggested binary format):**

```
[MSG_TYPE][SEQ_NUM][SRC_ID][DST_ID][METRICS][ROUTE_PATH]
```

* `MSG_TYPE`: 1B (RREQ=1, RREP=2, RERR=3)
* `SEQ_NUM`: 2B sequence number
* `SRC_ID` / `DST_ID`: node identifiers
* `METRICS`: tuple {bandwidth, latency, energy}
* `ROUTE_PATH`: list of intermediate hops

---

## 9. Deployment Workflow

On each laptop:

```bash
sudo /usr/local/sbin/ocb-up.sh 172.16.100.1
./dsr_daemon --config config.json
```

Repeat with unique IP + node ID per laptop.

Use Ansible or SSH for multi-node automation.

---

## 10. Debugging & Monitoring

* Capture packets:

  ```bash
  sudo tcpdump -i wlan0 -w nodeA_ocb.pcap
  ```
* Connectivity:

  ```bash
  ping 172.16.100.2
  ```
* Throughput:

  ```bash
  iperf3 -s       # Node A
  iperf3 -c 172.16.100.1   # Node B
  ```
* View stats:

  ```bash
  ip -s link show wlan0
  ```

---

## 11. Developer Notes

* Routing logic must handle **multi-hop** discovery and cache refresh.
* Metric collection:

  * Bandwidth: throughput probes
  * Latency: hello packet round-trip
  * Energy: mock or battery API
* Future work:

  * GPS/time integration
  * Mobility models for dynamic tests
  * Ansible-based auto-deployment

---

**Regulatory Note:**
The 5.9 GHz band (ITS-G5 / DSRC) is licensed in many regions. Use only in authorized test ranges or with special licenses. For early dev, OCB can be tested in unlicensed 5 GHz bands (not standards-compliant).

---

```

---

⚡ Now you have a **self-contained `.md` manual** (`MANET_TESTBED_GUIDE.md`) to keep in your repo. It covers **setup, config, CLI spec, protocol contract, and dev notes**.  

Do you also want me to create a **matching `ocb-up.sh` + example `config.json` files** so your team can clone & run right away, or just keep them embedded inside the `.md`?
```
