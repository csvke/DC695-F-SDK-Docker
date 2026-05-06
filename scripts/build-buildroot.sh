#!/bin/bash
# build-buildroot.sh — runs INSIDE the container
# Starts a named tmux session and runs the Buildroot build within it.
set -e

SESSION="buildroot-build"
BUILD_CMD="/tmp/dc695f-buildroot-run.sh"

cat > "$BUILD_CMD" << 'EOF'
#!/bin/bash
set -e
cd /workspace

echo "==========================================="
echo "DC695-F Buildroot Build"
echo "==========================================="

source buildroot/envsetup.sh
# envsetup.sh is interactive — select board when prompted, then:
make

echo ""
echo "Build complete!"
echo "Artifacts: /workspace/buildroot/output/<board>/"
echo "Firmware:  /workspace/output/firmware/"
echo ""
echo "Press Enter to close."
read
EOF

chmod +x "$BUILD_CMD"

echo ""
echo "==========================================="
echo "DC695-F Buildroot Build Environment"
echo "  tmux session : $SESSION"
echo "  Detach       : Ctrl+B, d"
echo "  Reattach     : docker exec -it dc695f-buildroot tmux attach -t $SESSION"
echo "==========================================="
echo ""

exec tmux new-session -s "$SESSION" bash "$BUILD_CMD"
