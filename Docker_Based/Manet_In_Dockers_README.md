# MANETs in Dockers Emulation

## Overview

This project sets up an **emulated Mobile Ad Hoc Network (MANET)** testbed on a **single Linux laptop** using:

* **mac80211\_hwsim** (virtual radios in the Linux kernel)
* **Docker containers** (each acting as a MANET node)
* **IBSS (ad-hoc) mode** for realistic link-layer behavior

The routing protocol (**custom DSR with multi-metric Dijkstra**) is implemented separately by the research team.

This README covers:

1. Software prerequisites
2. Creating virtual Wi-Fi radios with `hwsim`
3. Docker node setup and networking
4. Assigning IP addresses and forming an IBSS network
5. Running custom routing daemons
6. Debugging and monitoring

---

## 1. Software Requirements

* Ubuntu 22.04 LTS (or newer)
* Kernel ≥ 5.x with `mac80211_hwsim` module
* Packages:

```bash
sudo apt update
sudo apt install -y iw iproute2 wireless-tools tcpdump iperf3 git build-essential cmake docker.io
```

---

## 2. Create Virtual Radios

Load the `hwsim` module with N radios (example: 3 nodes):

```bash
sudo modprobe mac80211_hwsim radios=3
```

Check new interfaces:

```bash
iw dev
```

You should see `wlan0`, `wlan1`, `wlan2` (all virtual).

---

## 3. Docker Containers as MANET Nodes

Bind each virtual radio to a container (so each Docker = one node).

Example: run container with `wlan1`:

```bash
docker run -it --net=none --name node1 ubuntu:22.04 bash
```

Move interface into container namespace:

```bash
sudo ip link set wlan1 netns $(docker inspect -f '{{.State.Pid}}' node1)
```

Inside the container:

```bash
apt update && apt install -y iproute2 iw
ip link set wlan1 up
```

---

## 4. Join IBSS (Ad-hoc Mode)

Inside each node/container:

### Node1

```bash
iw dev wlan1 ibss join test-mesh 2412 HT20 fixed-freq 02:11:22:33:44:55
ip addr add 172.16.100.1/24 dev wlan1
```

### Node2

```bash
iw dev wlan2 ibss join test-mesh 2412 HT20 fixed-freq 02:11:22:33:44:55
ip addr add 172.16.100.2/24 dev wlan2
```

### Node3

```bash
iw dev wlan3 ibss join test-mesh 2412 HT20 fixed-freq 02:11:22:33:44:55
ip addr add 172.16.100.3/24 dev wlan3
```

---

## 5. Run Custom Routing Protocol

Once nodes can **ping each other**, launch your routing daemon:

```bash
./dsr_daemon --interface wlan1 --config config.json
```

Repeat per container.

---

## 6. Debugging and Monitoring

* **Check IBSS peers:**

```bash
iw dev wlan1 station dump
```

* **Sniff packets:**

```bash
tcpdump -i wlan1 -w node1_ibss.pcap
```

* **Throughput test:**

```bash
iperf3 -s   # node1
iperf3 -c 172.16.100.1   # node2
```

---

## Notes

* This setup **emulates multiple wireless MANET nodes on one laptop**.
* It does not capture mobility or wireless channel effects (you can script connectivity changes with `tc netem`).
* When hardware with OCB/802.11p support becomes available (ath9k, ath10k), you can **switch from IBSS to OCB** with minimal code changes.
