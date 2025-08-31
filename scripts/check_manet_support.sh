#!/bin/bash
# MANET Hardware Support Checklist
# Usage: ./check_manet_support.sh

echo "=== MANET Hardware Support Checklist ==="
echo

# 1. Kernel version
echo "[*] Kernel version:"
uname -r
echo

# 2. List detected network controllers
echo "[*] Network controllers:"
lspci -nnk | grep -iA3 net
echo

# 3. Active network interfaces
echo "[*] Active network interfaces:"
ip -o link show | awk -F': ' '{print $2}'
echo

# 4. Wireless chipset & driver
echo "[*] Wireless chipset & driver:"
lshw -C network | grep -E "product:|vendor:|driver="
echo

# 5. Supported interface modes (IBSS/OCB check)
echo "[*] Supported interface modes:"
iw list | grep -A 20 "Supported interface modes"
echo

# 6. Quick interpretation
if iw list | grep -q "IBSS"; then
    echo "[+] IBSS (ad-hoc mode) supported ✅"
else
    echo "[-] IBSS (ad-hoc mode) NOT supported ❌"
fi

if iw list | grep -q "OCB"; then
    echo "[+] OCB (802.11p / vehicular) supported ✅"
else
    echo "[-] OCB (802.11p / vehicular) NOT supported ❌"
fi

# 7. Monitor mode (useful for tcpdump/wireshark)
if iw list | grep -q "monitor"; then
    echo "[+] Monitor mode supported ✅"
else
    echo "[-] Monitor mode NOT supported ❌"
fi

echo
echo "=== Checklist Complete ==="
