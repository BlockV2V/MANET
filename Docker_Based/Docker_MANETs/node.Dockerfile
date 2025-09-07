FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    iproute2 iw wireless-tools tcpdump iperf3 net-tools iputils-ping \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root

# Keep container alive for testing
CMD ["tail", "-f", "/dev/null"]
