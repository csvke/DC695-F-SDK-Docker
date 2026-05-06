#!/bin/bash
# build-buildroot.sh - runs INSIDE the container
# Buildroot requires interactive board selection - always needs a TTY.
# Use: make buildroot-shell
set -e

SESSION="buildroot-build"

if [ ! -t 1 ]; then
    echo "ERROR: Buildroot requires interactive input (board selection)."
    echo "Run: make buildroot-shell"
    exit 1
fi

run_build() {
    set -e
    cd /workspace

    echo "=========================================="
    echo "DC695-F Buildroot Build"
    echo "=========================================="

    source buildroot/envsetup.sh
    make

    echo ""
    echo "Build complete!"
    echo "Artifacts: /workspace/buildroot/output/<board>/"
    echo "Firmware:  /workspace/output/firmware/"
    echo ""
    echo "Press Enter to close."
    read
}

export -f run_build

echo ""
echo "=========================================="
echo "DC695-F Buildroot Build Environment"
echo "  tmux session : $SESSION"
echo "  Detach       : Ctrl+B, d"
echo "  Reattach     : docker exec -it dc695f-buildroot tmux attach -t $SESSION"
echo "=========================================="
echo ""

exec tmux new-session -s "$SESSION" bash -c 'run_build'
