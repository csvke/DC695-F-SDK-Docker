#!/bin/bash
# build-yocto.sh - runs INSIDE the container
# Uses tmux when a TTY is available (interactive); runs directly when detached.
set -e

SESSION="yocto-build"

run_build() {
    set -e
    cd /workspace/yocto

    echo "=========================================="
    echo "DC695-F Yocto Build"
    echo "=========================================="

    echo "[1/2] Initialising BitBake build environment..."
    source oe-init-build-env build

    echo "[2/2] Running BitBake (core-image-minimal)..."
    bitbake core-image-minimal

    echo ""
    echo "Build complete!"
    echo "Images: /workspace/yocto/build/tmp/deploy/images/"
}

if [ -t 1 ]; then
    export -f run_build
    echo ""
    echo "=========================================="
    echo "DC695-F Yocto Build Environment"
    echo "  tmux session : $SESSION"
    echo "  Detach       : Ctrl+B, d"
    echo "  Reattach     : docker exec -it dc695f-yocto tmux attach -t $SESSION"
    echo "=========================================="
    echo ""
    exec tmux new-session -s "$SESSION" bash -c 'run_build; echo ""; echo "Press Enter to close."; read'
else
    run_build
fi
