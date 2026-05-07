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

    echo "[1/3] Initialising BitBake build environment..."
    source oe-init-build-env build

    # Redirect TMPDIR to a container-local path to avoid 'cp -p' ownership errors
    # when BitBake's do_unpack tries to chown files on the bind-mounted volume.
    # NOTE: oe-init-build-env changed CWD to /workspace/yocto/build, so local.conf
    # is at conf/local.conf (not build/conf/local.conf).
    YOCTO_TMPDIR="/yocto-tmp"
    mkdir -p "$YOCTO_TMPDIR"
    grep -q "^TMPDIR" conf/local.conf 2>/dev/null || \
        echo "TMPDIR = \"$YOCTO_TMPDIR\"" >> conf/local.conf
    # Disable uninative: the uninative cp binary fails with EINVAL when preserving
    # ownership on Docker overlay2. System tools in the container are sufficient.
    grep -q "^INHERIT:remove.*uninative" conf/local.conf 2>/dev/null || \
        echo 'INHERIT:remove = "uninative"' >> conf/local.conf
    # Prevent pseudo from intercepting operations on the bind-mounted workspace.
    grep -q "^PSEUDO_IGNORE_PATHS" conf/local.conf 2>/dev/null || \
        echo 'PSEUDO_IGNORE_PATHS .= ":/workspace"' >> conf/local.conf
    echo "  TMPDIR -> $YOCTO_TMPDIR (container-local, avoids chown errors)"

    echo "[2/3] Running BitBake (core-image-minimal)..."
    bitbake core-image-minimal

    echo "[3/3] Copying deploy artifacts to mounted volume..."
    mkdir -p /workspace/yocto/build/deploy
    cp -r "$YOCTO_TMPDIR/deploy/"* /workspace/yocto/build/deploy/ 2>/dev/null || true

    echo ""
    echo "Build complete!"
    echo "Images: /workspace/yocto/build/deploy/images/"
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
