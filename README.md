# DC695-F SDK Docker Build Environment

Reproducible Docker build environments for the Rockchip RK3576 DC695-F Linux SDK.

**Architecture:** Build tools in Docker, SDK mounted from host (SDK is private and not included here)

## Change Log

- **DF-7**: Initial scaffold — Buildroot, Debian (Bookworm), Ubuntu (Jammy), Yocto build environments

## Environments

| Service | Distro | Base image |
|---|---|---|
| `buildroot` | Buildroot | Ubuntu 24.04 |
| `debian` | Debian Bookworm (arm64 / armhf) | Ubuntu 24.04 |
| `ubuntu` | Ubuntu Jammy 22.04 (arm64) | Ubuntu 24.04 |
| `yocto` | Yocto / Poky + meta-rockchip | Ubuntu 24.04 |

## Features

- Based on Ubuntu 24.04 LTS
- All build dependencies pre-installed per target
- SDK mounted from host — editable and persistent, no re-copy needed
- Privileged mode + root user (required for `binfmt_misc`, chroot, `mke2fs -d`)
- `tmux` pre-installed for persistent build sessions

## Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+ (plugin or standalone)
- 60GB+ free disk space (SDK ~20GB + build outputs per target)
- 16GB+ RAM recommended (Yocto needs 8GB minimum)

### Host OS compatibility

| Host OS | Support | Notes |
|---|---|---|
| **Ubuntu 22.04 / 24.04** | ✅ Recommended | Native Linux — best performance, no caveats |
| **Mac (Docker Desktop)** | ⚠️ Works with caveats | Slower volume mounts; root-owned `binary/` files may be hard to clean up from host |
| **Windows (Docker Desktop + WSL2)** | ⚠️ Works with caveats | Keep repos inside WSL2 filesystem (`~/...`), not under `/mnt/c/` |

> **Recommendation:** Use a native **Ubuntu Linux** host. The Debian and Ubuntu builds create root-owned chroot directories, mount `binfmt_misc`, and run privileged containers — all seamless on Linux.

## Recommended Folder Structure

Keep the SDK and this repo as siblings under a shared workspace root, mirroring the RV1126B-P setup:

```
~/Fanconn DC695-F/
├── DC695-F-SDK-Docker/     ← this repo (public)
├── SDK/
│   └── rk3576_linux6.1_sdk_stan_rkr6_250121/   ← SDK (private, obtain separately)
├── Docs/
└── Fanconn DC695-F.code-workspace
```

The `docker-compose.yml` default paths assume this layout:
- `SDK_PATH` defaults to `../SDK/rk3576_linux6.1_sdk_stan_rkr6_250121`
- `HOST_DC695F_PATH` defaults to `..` (the workspace root, mounted at `/workspace-host`)

## Quick Start

### Step 0: Obtain the SDK

The SDK is distributed by Fanconn/Rockchip and is **not included in this repository**. Place it at the expected path:

```bash
# Example: extract vendor-provided archive
mkdir -p ~/Fanconn\ DC695-F/SDK
cd ~/Fanconn\ DC695-F/SDK
cat rk3576_linux6.1_sdk_stan_rkr6_250121.tar.gz* | tar xz
```

### Step 1: Clone this repo

```bash
cd ~/Fanconn\ DC695-F
git clone <this-repo-url> DC695-F-SDK-Docker
cd DC695-F-SDK-Docker
```

### Step 2: Build the base image first

```bash
docker compose build base
```

### Step 3: Build and run a target

```bash
# Buildroot
docker compose build buildroot
docker compose run --rm buildroot

# Debian (Bookworm, arm64)
docker compose build debian
docker compose run --rm debian

# Ubuntu (Jammy, arm64)
docker compose build ubuntu
docker compose run --rm ubuntu

# Yocto
docker compose build yocto
docker compose run --rm yocto
```

### Override SDK path (if your layout differs)

```bash
SDK_PATH=/path/to/rk3576_sdk docker compose run --rm debian
```

## Build Artifacts

All paths are relative to `/workspace` (SDK root inside the container), which maps directly to your host filesystem — nothing is trapped in the container.

| Target | Intermediate output | Final images |
|---|---|---|
| **Buildroot** | `buildroot/output/<board>/` | `output/firmware/` → symlinked into `rockdev/` |
| **Debian** | `debian/binary/` (chroot tree) | `debian/linaro-rootfs.img` → packed into `output/firmware/` |
| **Ubuntu** | `ubuntu/binary/` (chroot tree) | rootfs image in `ubuntu/` → packed into `output/firmware/` |
| **Yocto** | `yocto/build/tmp/deploy/images/<machine>/` | BitBake writes directly here |

**Final flashable firmware** (Buildroot / Debian / Ubuntu):
- `output/firmware/` — individual partition images (`boot.img`, `rootfs.img`, `uboot.img`, etc.)
- `rockdev/` — symlinks to the above, consumed by `rkflash.sh` and `update_tool`
- `output/firmware/update.img` — packed single-file OTA image

> **Note:** Debian and Ubuntu builds create root-owned `binary/` chroot directories on the host. On Mac/Windows Docker Desktop, use `docker exec` to `rm -rf` them from inside the container rather than from the host.

## Build Instructions (inside container)

### Buildroot

```bash
source buildroot/envsetup.sh
# Select board
make
```

### Debian (Bookworm, arm64)

```bash
cd /workspace/debian
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f
RELEASE=bookworm TARGET=base ARCH=arm64 ./mk-base-debian.sh
RELEASE=bookworm ARCH=arm64 ./mk-rootfs.sh
./mk-image.sh
```

### Ubuntu (Jammy, arm64)

```bash
cd /workspace/ubuntu
VERSION=debug ARCH=arm64 ./mk-rootfs.sh jammy
```

### Yocto

```bash
cd /workspace/yocto
source oe-init-build-env build
bitbake core-image-minimal
```
