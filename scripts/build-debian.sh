#!/bin/bash
# build-debian.sh - runs INSIDE the container
# Uses tmux when a TTY is available (interactive); runs directly when detached.
set -e

SESSION="debian-build"

run_build() {
    set -e
    cd /workspace/debian

    echo "=========================================="
    echo "DC695-F Debian (Bookworm) Build  [arm64]"
    echo "=========================================="

    echo "[1/4] Installing ubuntu-build-service packages..."
    sudo dpkg -i ubuntu-build-service/packages/*
    sudo apt-get install -f -y

    echo "[2/4] Building base Debian system from Linaro..."
    # Patch SDK typo: 'bookwrom' -> 'bookworm' in live-build configure script
    CONFIGURE="ubuntu-build-service/bookworm-base-arm64/configure"
    if grep -q 'bookwrom' "$CONFIGURE" 2>/dev/null; then
        sed -i 's/--distribution bookwrom/--distribution bookworm/g' "$CONFIGURE"
        echo "  (patched $CONFIGURE: bookwrom -> bookworm)"
    fi
    RELEASE=bookworm TARGET=base ARCH=arm64 ./mk-base-debian.sh

    echo "[3/4] Building rootfs overlay (Rockchip hw accel)..."
    RELEASE=bookworm ARCH=arm64 ./mk-rootfs.sh

    echo "[4/4] Creating ext4 image..."
    ./mk-image.sh

    echo ""
    echo "Build complete!"
    echo "Rootfs image : /workspace/debian/linaro-rootfs.img"
    echo "Firmware dir : /workspace/output/firmware/"
}

if [ -t 1 ]; then
    export -f run_build
    echo ""
    echo "=========================================="
    echo "DC695-F Debian (Bookworm) Build Environment"
    echo "  tmux session : $SESSION"
    echo "  Detach       : Ctrl+B, d"
    echo "  Reattach     : docker exec -it dc695f-debian tmux attach -t $SESSION"
    echo "=========================================="
    echo ""
    exec tmux new-session -s "$SESSION" bash -c 'run_build; echo ""; echo "Press Enter to close."; read'
else
    run_build
fi
