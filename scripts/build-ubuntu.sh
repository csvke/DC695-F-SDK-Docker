#!/bin/bash
# build-ubuntu.sh — runs INSIDE the container
# Starts a named tmux session and runs the Ubuntu (Jammy) rootfs build within it.
set -e

SESSION="ubuntu-build"
BUILD_CMD="/tmp/dc695f-ubuntu-run.sh"

cat > "$BUILD_CMD" << 'EOF'
#!/bin/bash
set -e
cd /workspace/ubuntu

echo "==========================================="
echo "DC695-F Ubuntu (Jammy 22.04) Build  [arm64]"
echo "==========================================="

echo "[1/1] Building Ubuntu rootfs..."
VERSION=debug ARCH=arm64 ./mk-rootfs.sh jammy

echo ""
echo "Build complete!"
echo "Rootfs dir   : /workspace/ubuntu/binary/"
echo "Firmware dir : /workspace/output/firmware/"
echo ""
echo "Press Enter to close."
read
EOF

chmod +x "$BUILD_CMD"

echo ""
echo "==========================================="
echo "DC695-F Ubuntu (Jammy) Build Environment"
echo "  tmux session : $SESSION"
echo "  Detach       : Ctrl+B, d"
echo "  Reattach     : docker exec -it dc695f-ubuntu tmux attach -t $SESSION"
echo "==========================================="
echo ""

exec tmux new-session -s "$SESSION" bash "$BUILD_CMD"
