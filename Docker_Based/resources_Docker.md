# RESOURCES – Docker-Based MANET Testbed Setup

This document collects **documentation, guides, and video resources** to help set up
and test **ad-hoc (IBSS) networking** and **MANET environments** inside **Docker containers**  
using **mac80211_hwsim** (virtual radios) on Ubuntu.

---

## 📘 Official & Community Documentation

### Linux Wireless Wiki – mac80211_hwsim
- Canonical reference for the Linux kernel’s **virtual Wi-Fi radio driver**.  
- Explains how to create multiple virtual radios for testing MANET protocols.  
🔗 [Linux Wireless Wiki: mac80211_hwsim](https://wireless.wiki.kernel.org/en/users/Drivers/mac80211_hwsim)

---

### Docker Networking – Custom Interfaces
- Explains how to run Docker containers with **custom network namespaces** and attach
them to **virtual radios**.  
🔗 [Docker Docs: Network Configuration](https://docs.docker.com/network/)

---

### Mininet-WiFi (Optional Extension)
- Simulator that integrates with Docker-style namespaces for **wireless MANET emulation**.  
- Useful if you want mobility models and dynamic topologies.  
🔗 [Mininet-WiFi Documentation](https://mininet-wifi.github.io/)

---

### ArchWiki – Ad-hoc Networking
- Still relevant for configuring `iw dev wlan0 ibss join …` inside containers.  
- Use the same CLI inside Docker as you would on bare metal.  
🔗 [ArchWiki: Ad-hoc networking](https://wiki.archlinux.org/title/Ad-hoc_networking?utm_source=chatgpt.com)

---

## 🎥 YouTube Tutorials

1. **mac80211_hwsim Virtual Wi-Fi Interfaces**  
   Walkthrough of creating multiple virtual radios for Linux networking experiments.  
   🔗 [Watch here](https://www.youtube.com/watch?v=Lp1nFxOaM9M&utm_source=chatgpt.com)

2. **Docker Networking Explained**  
   General introduction to container networking – useful before attaching custom radios.  
   🔗 [Watch here](https://www.youtube.com/watch?v=bKFMS5C4CG0&utm_source=chatgpt.com)

3. **Mininet-WiFi MANET Demo (Optional)**  
   Demonstrates wireless emulation with mobility support.  
   🔗 [Watch here](https://www.youtube.com/watch?v=llWguQpoygA&utm_source=chatgpt.com)

---

## 🛠️ Suggested Tools for Docker MANET Testing

- **tcpdump / Wireshark** → packet capture from inside containers  
- **iperf3** → throughput and latency benchmarking  
- **iproute2 / iw** → interface management inside containers  
- **docker-compose** → multi-node orchestration  
- **ansible** → automation across many containers or hosts  

---

## 📚 Recommended Reading

- RFC 4728 – **Dynamic Source Routing (DSR)** Protocol  
- RFC 3561 – **Ad hoc On-Demand Distance Vector (AODV)** Routing  
- Linux Wireless Wiki – [https://wireless.wiki.kernel.org](https://wireless.wiki.kernel.org)  
- “Docker Networking Handbook” – covers advanced namespace and custom NIC binding  

---

## ✅ Usage Notes for Docker MANET

- Load `mac80211_hwsim` first to create virtual radios:
  ```bash
  sudo modprobe mac80211_hwsim radios=5
  iw dev
  ```
- Launch containers in **`--net=none`** mode and attach them to virtual radios manually:
  ```bash
  docker run -it --rm --net=none --privileged manet-node bash
  ```
- Inside container, configure IBSS:
  ```bash
  ip link set wlan0 down
  iw dev wlan0 set type ibss
  ip link set wlan0 up
  iw dev wlan0 ibss join mymanet 2412
  ip addr add 172.16.100.1/24 dev wlan0
  ```
- Disable Wi-Fi power saving inside containers:
  ```bash
  iw dev wlan0 set power_save off
  ```

---

🚀 With these references you can build a **Docker-based MANET testbed**  
that behaves like a real wireless mesh but runs entirely on one laptop.

