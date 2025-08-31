# RESOURCES – Ubuntu Ad-Hoc & MANET Testbed Setup

This document collects **documentation, guides, and video resources** to help set up
and test **ad-hoc (IBSS) networking** and **MANET environments** on **Ubuntu**.

---

## 📘 Official & Community Documentation

### Ubuntu Community Wiki – Ad-Hoc Setup
- Step-by-step instructions for both **GUI (NetworkManager)** and **CLI (iwconfig/ip)** setups.  
- Covers SSID creation, IP assignment, and testing connectivity.  
🔗 [Ubuntu Community Docs: WifiDocs/Adhoc](https://help.ubuntu.com/community/WifiDocs/Adhoc?utm_source=chatgpt.com)

---

### Debian Wiki – Ad-Hoc Mode
- Reliable reference that also works for Ubuntu.  
- Focused on CLI configuration via `iwconfig`, `ifconfig`, and static IPs.  
🔗 [Debian Wiki: WiFi/AdHoc](https://wiki.debian.org/WiFi/AdHoc?utm_source=chatgpt.com)

---

### ArchWiki – Ad-hoc Networking
- Generic but very complete, useful for **advanced Ubuntu users**.  
- Demonstrates `iw dev wlan0 ibss join ...` and optional `wpa_supplicant`.  
🔗 [ArchWiki: Ad-hoc networking](https://wiki.archlinux.org/title/Ad-hoc_networking?utm_source=chatgpt.com)

---

### Digi Embedded – Using wpa_supplicant for IBSS
- Shows how to configure secure ad-hoc networks in **modern Linux** environments.  
- Example config for `/etc/wpa_supplicant/wpa_supplicant.conf`.  
🔗 [Digi KB: Wi-Fi Ad Hoc with wpa_supplicant](https://www.digi.com/support/knowledge-base/how-to-create-a-wifi-ad-hoc-connection-with-wpa-su?utm_source=chatgpt.com)

---

## 🎥 YouTube Tutorials

1. **How to Create Ad-Hoc Network on Linux (Practical Setup)**  
   Simple video showing ad-hoc network setup on Linux laptops.  
   🔗 [Watch here](https://www.youtube.com/watch?v=Uy5F9SuVaHQ&utm_source=chatgpt.com)

2. **IEEE 802.11 Ad-Hoc Wireless LANs – Architecture & Basics**  
   Explains the difference between infrastructure and ad-hoc, with protocol context.  
   🔗 [Watch here](https://www.youtube.com/watch?v=Q4iQt6FOnXI&utm_source=chatgpt.com)

---

## 🛠️ Suggested Tools for Ubuntu MANET Testing

- **tcpdump / Wireshark** → for packet capture and protocol debugging  
- **iperf3** → throughput and latency benchmarking  
- **net-tools & iproute2** → interface management (`iw`, `ip`, `ifconfig`)  
- **wpa_supplicant** → optional secure ad-hoc connections  
- **ansible or ssh** → multi-node automation

---

## 📚 Recommended Reading

- RFC 3561 – **Ad hoc On-Demand Distance Vector (AODV)** Routing  
- RFC 4728 – **Dynamic Source Routing (DSR)** Protocol  
- Linux Wireless Wiki – [https://wireless.wiki.kernel.org](https://wireless.wiki.kernel.org)

---

## ✅ Usage Notes for Ubuntu

- On Ubuntu 22.04+, **NetworkManager GUI** supports ad-hoc creation but often defaults to WPA2-PSK → not ideal for raw MANET. Prefer CLI.  
- Always disable power-saving on Wi-Fi NICs:
  ```bash
  sudo iw dev wlan0 set power_save off
