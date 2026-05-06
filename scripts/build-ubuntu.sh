#!/bin/bash
# build-ubuntu.sh - runs INSIDE the container
# Uses tmux when a TTY is available (interactive); runs directly when detached.
set -e

SESSION="ubuntu-build"

run_build() {
    set -e
    cd /workspace/ubuntu

    echo "=========================================="
    echo "DC695-F Ubuntu (Jammy 22.04) Build  [arm64]"
    echo "=========================================="

    echo "[1/1] Building Ubuntu rootfs..."
    VERSION=debug ARCH=arm64 ./mk-rootfs.sh jammy

    echo ""
    echo "Build complete!"
    echo "Rootfs dir   : /workspace/ubuntu/binary/"
    echo "Firmware dir : /workspace/output/firmware/"
}

if [ -t 1 ]; then
    export -f run_build
    echo ""
    echo "=========================================="
    echo "DC695-F Ubuntu (Jammy) Build Environment"
    echo "  tmux session : $SESSION"
    echo "  Detach       : Ctrl+B, d"
    echo "  Reattach     : docker exec -it dc695f-ubuntu tmux attach -t $SESSION"
    echo "=========================================="
    echo ""
    exec tmux new-session -s "$SESSION" bash -c 'run_build; echo ""; echo "Press Enter to close."; read'
else
    run_build
fi
