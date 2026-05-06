#!/bin/bash
# build-yocto.sh — runs INSIDE the container
# Starts a named tmux session and runs the Yocto build within it.
set -e

SESSION="yocto-build"
BUILD_CMD="/tmp/dc695f-yocto-run.sh"

cat > "$BUILD_CMD" << 'EOF'
#!/bin/bash
set -e
cd /workspace/yocto

echo "==========================================="
echo "DC695-F Yocto Build"
echo "==========================================="

echo "[1/2] Initialising BitBake build environment..."
source oe-init-build-env build

echo "[2/2] Running BitBake (core-image-minimal)..."
bitbake core-image-minimal

echo ""
echo "Build complete!"
echo "Images: /workspace/yocto/build/tmp/deploy/images/"
echo ""
echo "Press Enter to close."
read
EOF

chmod +x "$BUILD_CMD"

echo ""
echo "==========================================="
echo "DC695-F Yocto Build Environment"
echo "  tmux session : $SESSION"
echo "  Detach       : Ctrl+B, d"
echo "  Reattach     : docker exec -it dc695f-yocto tmux attach -t $SESSION"
echo "==========================================="
echo ""

exec tmux new-session -s "$SESSION" bash "$BUILD_CMD"
