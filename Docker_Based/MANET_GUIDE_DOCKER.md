# MANET Testbed Guide – Custom DSR + Multi-Metric Dijkstra (Docker Emulation)

This document describes how to set up an **emulated MANET testbed on a single Linux laptop**
using:

- `mac80211_hwsim` (virtual radios in the Linux kernel)  
- **Docker containers** (each acting as a MANET node)  
- **IBSS (ad-hoc) mode** for realistic L2 behavior  

The routing protocol (custom **DSR** with **multi-metric Dijkstra**) is implemented separately.

---

## 1. Requirements

**Host Machine**
- Linux laptop (Ubuntu 22.04 LTS recommended)
- Kernel ≥ 5.x with `mac80211_hwsim`

**Packages**
```bash
sudo apt update
sudo apt install -y iw iproute2 wireless-tools tcpdump iperf3 \
                    git build-essential cmake util-linux \
                    docker.io docker-compose
```

Optional:

* `chrony` or `ntp` for clock sync
* `ansible` for container orchestration (multi-host extension)

---

## 2. Virtual Radios with `mac80211_hwsim`

Load the module with N radios:

```bash
sudo modprobe mac80211_hwsim radios=5
```

Check created interfaces:

```bash
iw dev
```

You should see `wlan0`, `wlan1`, etc. — one per virtual radio.

---

## 3. Docker Node Setup

Each container = 1 MANET node.

Create a base image `Dockerfile`:

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y iproute2 iw tcpdump iperf3 \
                       python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

COPY dsr_daemon /usr/local/bin/dsr_daemon
COPY config.json /root/config.json
```

Build:

```bash
docker build -t manet-node .
```

---

## 4. IBSS Mode Setup inside Containers

Attach each container to a virtual radio (`--net=none` + `--device`):

Example start script:

```bash
docker run -it --rm \
  --net=none \
  --name nodeA \
  --device /dev/net/tun \
  --privileged \
  manet-node bash
```

Inside container, bind to radio:

```bash
ip link set wlan0 down
iw dev wlan0 set type ibss
ip link set wlan0 up
iw dev wlan0 ibss join mymanet 2412
ip addr add 172.16.100.1/24 dev wlan0
```

Repeat with unique IP for each container.

---

## 5. Routing Daemon Specification

The **routing daemon** (`dsr_daemon`) will:

* Bind to container’s `wlanX`  
* Exchange DSR control messages:

  * RREQ (Route Request)  
  * RREP (Route Reply)  
  * RERR (Route Error)  

* Apply **multi-metric Dijkstra** for best path selection  
* Maintain a route cache with expiration  

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

```bash
./dsr_daemon --config config.json
```

Options:

```
  --interface wlan0         # interface
  --ip 172.16.100.1         # local IP
  --id nodeA                # logical ID
  --log-level info          # logging
  --dump-routes routes.txt  # debug routes
```

---

## 8. Protocol Behavior

**Suggested packet header layout:**

```
[MSG_TYPE][SEQ_NUM][SRC_ID][DST_ID][METRICS][ROUTE_PATH]
```

- MSG_TYPE: 1B (RREQ=1, RREP=2, RERR=3)  
- SEQ_NUM: 2B sequence number  
- METRICS: {bw, latency, energy}  
- ROUTE_PATH: hop list  

---

## 9. Deployment Workflow

1. Load radios:
   ```bash
   sudo modprobe mac80211_hwsim radios=5
   ```

2. Start N containers with different radios.  
   Assign static IPs inside each container.  

3. Run daemon:
   ```bash
   ./dsr_daemon --config config.json
   ```

---

## 10. Debugging & Monitoring

* Packet capture:
  ```bash
  tcpdump -i wlan0 -w nodeA_ibss.pcap
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

---

## 11. Developer Notes

- Metrics:
  * Bandwidth → iperf probing  
  * Latency → hello packet RTT  
  * Energy → mocked or sensor input  

- Future extensions:
  * Mobility emulation (Mininet-WiFi, ns-3 integration)  
  * Ansible-based orchestration across many laptops  
  * Migration from IBSS → OCB when hardware available  

---

⚠ **Note**: IBSS emulation is a **proxy** for real vehicular 802.11p.  
When hardware support is ready, replace Docker radios with real NICs + OCB.

