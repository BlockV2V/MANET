README – MANET Testbed for Custom DSR + Multi-Metric Dijkstra
=============================================================

Overview
--------
This project sets up a physical Mobile Ad Hoc Network (MANET) testbed
on Linux laptops using IEEE 802.11 OCB mode (802.11p / ITS-G5).
The routing protocol (custom DSR with multi-metric Dijkstra) is
implemented separately by the research team.

This README covers:
1. Hardware & software prerequisites
2. Interface configuration (OCB mode)
3. IP addressing and topology
4. Starting/stopping the testbed
5. Deployment workflow across multiple laptops
6. Debugging and monitoring tools
7. Notes on regulatory/legal use

------------------------------------------------------------------------

1. Hardware & Software Requirements
-----------------------------------
- Linux laptops (Ubuntu 22.04 LTS recommended)
- Wi-Fi interfaces supporting OCB (Outside the Context of a BSS)
  * Suggested chipsets: Atheros ath9k/ath10k, some mt76
- Kernel ≥ 5.x with cfg80211 OCB support
- Packages:
    sudo apt update
    sudo apt install -y iw iproute2 wireless-tools tcpdump iperf3 git build-essential cmake

Optional:
- GPS USB dongle + gpsd (if protocol needs geo-location)
- Chrony or NTP for time synchronization
- Ansible (for multi-laptop automation)

------------------------------------------------------------------------

2. Configure OCB Mode on Wi-Fi Interface
----------------------------------------
Replace wlan0 with the actual device name.

# Bring interface down
sudo ip link set wlan0 down

# Set type to OCB
sudo iw dev wlan0 set type ocb

# Bring interface up
sudo ip link set wlan0 up

# Join ITS channel (example: 5890 MHz, 10 MHz bandwidth)
sudo iw dev wlan0 ocb join 5890 10MHZ

# Assign static IP (unique per laptop)
sudo ip addr add 172.16.100.X/24 dev wlan0

Verify:
iw dev wlan0 info
iw dev wlan0 ocb show
ip -s link show wlan0

------------------------------------------------------------------------

3. IP Addressing and Topology
------------------------------
- Each laptop is assigned a static IP in the 172.16.100.0/24 subnet.
- Example:
  Node A: 172.16.100.1
  Node B: 172.16.100.2
  Node C: 172.16.100.3
- The routing daemon (custom DSR/Dijkstra) will bind to this interface
  and manage multi-hop forwarding.

------------------------------------------------------------------------

4. Starting and Stopping the Testbed
------------------------------------
Recommended: use a helper script `ocb-up.sh` for repeatable setup.

Example script (place in /usr/local/sbin/ocb-up.sh):

#!/bin/bash
IF=wlan0
IPADDR=$1
FREQ=5890
BW=10MHZ

sudo iw reg set DE              # Set regulatory domain (adjust as needed)
sudo ip link set $IF down
sudo iw dev $IF set type ocb
sudo ip link set $IF up
sudo iw dev $IF ocb join $FREQ $BW
sudo ip addr flush dev $IF
sudo ip addr add $IPADDR/24 dev $IF

Usage per node:
sudo /usr/local/sbin/ocb-up.sh 172.16.100.10

Stop:
sudo ip link set wlan0 down

------------------------------------------------------------------------

5. Deployment Workflow (Multi-Laptop)
-------------------------------------
- Each laptop runs the same configuration script with a unique IP.
- Routing daemon (custom DSR/Dijkstra) is launched afterwards:
  ./dsr_daemon --interface wlan0 --config config.json
- Use Ansible or SSH to push binaries and start daemons on all laptops.

------------------------------------------------------------------------

6. Debugging and Monitoring
----------------------------
- Capture raw packets:
  sudo tcpdump -i wlan0 -w nodeA_ocb.pcap
- View in Wireshark (supports 802.11 OCB dissector).
- Test IP connectivity:
  ping 172.16.100.X
- Test throughput:
  iperf3 -s (on one node)
  iperf3 -c 172.16.100.Y (on another)
- View interface stats:
  ip -s link show wlan0

------------------------------------------------------------------------

7. Regulatory / Legal Note
--------------------------
The 5.9 GHz band is regulated. Transmitting without authorization
may be illegal in your jurisdiction.
Options:
- Use licensed test ranges or shielded RF chambers.
- Obtain explicit test licenses.
- For early software development, you may test with
  *non-ITS* frequencies in 5 GHz using OCB (not standard compliant).

------------------------------------------------------------------------

Next Steps for Researchers
--------------------------
- Integrate the custom DSR + multi-metric Dijkstra daemon.
- Define routing message formats (RREQ, RREP, RERR).
- Bind socket communication to wlan0 (OCB interface).
- Extend with GPS/time metrics if required.
- Use the above testbed setup for controlled field experiments.

------------------------------------------------------------------------
