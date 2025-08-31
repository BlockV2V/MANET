# Logging, Analyzing, and Debugging Tools for MANET Testbed

This document lists recommended **tools, techniques, and metrics** for evaluating your **custom DSR + multi-metric Dijkstra VANET testbed**. It is divided into **Docker-based emulation** and **physical Linux PC deployments**.

---

## 1) Docker-Based MANET Emulated Setup

### ✅ Metrics to Measure
- **Bandwidth**: per-link throughput, aggregate network utilization  
- **Computation cost**: CPU usage per container, crypto signing/verification overhead  
- **Space cost**: storage per node (full blocks, headers, cache)  
- **Mobility (emulated)**: topology changes simulated via script-based link up/down  
- **Packet loss / packet size / transmission times / delays**: per-packet statistics  
- **Battery (simulated)**: CPU cycles or estimated energy consumption  

### 🛠 Tools & Technologies

| Metric | Tools/Method |
|--------|--------------|
| Bandwidth | `iperf3` between containers, `docker stats` for network throughput, Wireshark/tcpdump captures |
| Computation cost | `docker stats`, `htop` inside container, Python `time` for crypto ops |
| Space cost | `du -sh /root/blockchain/` inside container, log filesystem usage |
| Packet loss / size / transmission | `tcpdump` + Wireshark, custom logging in routing daemon (timestamps, seq numbers) |
| Delays | Log packet send/receive timestamps in daemon, calculate RTT per hop |
| Emulated mobility | Scripts that bring container interfaces up/down, update routes, record topology changes |
| Battery / energy | Simulated via CPU utilization × time; can assign energy cost per operation in daemon logs |

### 🔧 Debugging & Logging Techniques
- **Centralized logging**: Use a volume mount and send all container logs to a host folder.
- **Daemon logs**: Log every RREQ/RREP/RERR with sequence number, timestamp, metrics used in route selection.
- **Wireshark**: Capture virtual Wi-Fi frames from `mac80211_hwsim` interface.  
- **Grafana / Prometheus**: Optional monitoring stack to visualize metrics (CPU, bandwidth, packet counts).
- **Scripts**: Automate extraction of metrics from logs (`grep`, `awk`, `jq` for JSON logs).

### 🔒 Security Analysis (Docker)
- **Wormhole attacks**: Log unexpected low-latency links; cross-check route hops.  
- **Sybil attacks**: Monitor multiple node IDs using the same interface/MAC.  
- **Blackhole attacks**: Track routes where packets are dropped unexpectedly by a node.  
- **Detection method**: Compare logged route discovery vs actual packet delivery; visualize with Wireshark.

---

## 2) Physical Linux PC Testbed

### ✅ Metrics to Measure
- Bandwidth (real wireless link utilization)  
- Computation cost (CPU + crypto)  
- Space cost (blockchain storage, logs)  
- Mobility (actual movement of laptops/cars)  
- Packet loss / packet size / transmission / delays  
- Battery consumption (laptops, embedded boards)  

### 🛠 Tools & Technologies

| Metric | Tools/Method |
|--------|--------------|
| Bandwidth | `iperf3`, `bmon`, Wireshark/tcpdump captures |
| Computation cost | `top`, `htop`, `perf stat`, `time` for daemon CPU profiling |
| Space cost | `du -sh /var/lib/manet/` or blockchain directory |
| Packet loss / size / transmission | Wireshark, tcpdump, daemon logs |
| Delays | Timestamp send/receive inside daemon, measure RTT |
| Mobility | GPS logging (if using USB GPS or smartphones), manual logging of movement |
| Battery | Laptop battery API (`upower -i /org/freedesktop/UPower/devices/battery_BAT0`) or Arduino/ESP32 telemetry |

### 🔧 Debugging & Logging Techniques
- **Distributed logging**: Each node writes to local logs, optionally collect via SSH/rsync or Ansible.  
- **Wireshark on wireless interfaces**: Capture 802.11 frames, inspect DSR packets + ABCD/Blockchain TLVs.  
- **tcpdump**: Command-line capture on multiple nodes.  
- **Prometheus/Grafana**: Optional, if each node can export metrics via HTTP endpoint.  
- **Route visualization**: Plot hop-by-hop paths and delays from log data.

### 🔒 Security Analysis (Physical)
- **Wormhole attacks**: Detect suspiciously short paths, latency anomalies in logs.  
- **Sybil attacks**: Monitor repeated MAC or node IDs; detect multiple identities claiming same location.  
- **Blackhole attacks**: Compare sent vs received packet counts, detect nodes dropping traffic.  
- **Other attacks to log**: DoS (flooding), route cache poisoning, replay attacks.  
- **Tools for detection**: Custom logging in daemon, Wireshark captures, statistical analysis scripts.

---

## 📌 Best Practices
1. **Synchronized time**: Use `chrony` or `ntp` to timestamp logs accurately across nodes.  
2. **Centralized collection**: Optional syslog server or mounted shared volume for Docker nodes.  
3. **Automate analysis**: Scripts to parse log files and produce CSV/graphs for bandwidth, delay, loss, CPU, battery.  
4. **Security evaluation**: Run controlled attacks in the emulation environment first before testing on real laptops.  

---

This setup allows your FYP to **quantitatively compare performance, energy, storage, and security** in both **emulated** and **real MANET environments**, providing rigorous evidence for results.  

