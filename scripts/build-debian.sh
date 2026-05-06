#!/bin/bash
# build-debian.sh — runs INSIDE the container
# Starts a named tmux session and runs the Debian (Bookworm) rootfs build within it.
set -e

SESSION="debian-build"
BUILD_CMD="/tmp/dc695f-debian-run.sh"

cat > "$BUILD_CMD" << 'EOF'
#!/bin/bash
set -e
cd /workspace/debian

echo "==========================================="
echo "DC695-F Debian (Bookworm) Build  [arm64]"
echo "==========================================="

echo "[1/4] Installing ubuntu-build-service packages..."
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f -y

echo "[2/4] Building base Debian system from Linaro..."
RELEASE=bookworm TARGET=base ARCH=arm64 ./mk-base-debian.sh

echo "[3/4] Building rootfs overlay (Rockchip hw accel)..."
RELEASE=bookworm ARCH=arm64 ./mk-rootfs.sh

echo "[4/4] Creating ext4 image..."
./mk-image.sh

echo ""
echo "Build complete!"
echo "Rootfs image : /workspace/debian/linaro-rootfs.img"
echo "Firmware dir : /workspace/output/firmware/"
echo ""
echo "Press Enter to close."
read
EOF

chmod +x "$BUILD_CMD"

echo ""
echo "==========================================="
echo "DC695-F Debian (Bookworm) Build Environment"
echo "  tmux session : $SESSION"
echo "  Detach       : Ctrl+B, d"
echo "  Reattach     : docker exec -it dc695f-debian tmux attach -t $SESSION"
echo "==========================================="
echo ""

exec tmux new-session -s "$SESSION" bash "$BUILD_CMD"
