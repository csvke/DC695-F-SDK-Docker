# DC695-F SDK Docker Build Environment
# Usage: make [SDK_PATH=<path>] <target>
#
# Targets:
#   build-base        Build the shared base Docker image
#
#   buildroot         Build Buildroot image + start build (tmux session inside container)
#   buildroot-shell   Build Buildroot image, drop into interactive bash
#
#   debian            Build Debian (Bookworm) image + start build (tmux)
#   debian-shell      Build Debian image, drop into interactive bash
#
#   ubuntu            Build Ubuntu (Jammy) image + start build (tmux)
#   ubuntu-shell      Build Ubuntu image, drop into interactive bash
#
#   yocto             Build Yocto image + start build (tmux)
#   yocto-shell       Build Yocto image, drop into interactive bash
#
# Reattach to a running build:
#   docker exec -it dc695f-<target> tmux attach -t <target>-build

SDK_PATH         ?= ../SDK/rk3576_linux6.1_sdk_stan_rkr6_250121
HOST_DC695F_PATH ?= ..
IMAGE_TAG        ?= latest

export SDK_PATH HOST_DC695F_PATH IMAGE_TAG

.PHONY: all help build-base check-sdk \
        buildroot buildroot-shell buildroot-build \
        debian    debian-shell    debian-build    \
        ubuntu    ubuntu-shell    ubuntu-build    \
        yocto     yocto-shell     yocto-build

all: help

# ── SDK path validation ───────────────────────────────────────────────────────
check-sdk:
	@if [ ! -d "$(SDK_PATH)" ]; then \
		echo ""; \
		echo "ERROR: SDK not found at: $(SDK_PATH)"; \
		echo ""; \
		echo "Set SDK_PATH to the correct location, e.g.:"; \
		echo "  make debian SDK_PATH=/path/to/rk3576_sdk"; \
		echo ""; \
		exit 1; \
	fi
	@echo "SDK: $(SDK_PATH)"

# ── Base image ────────────────────────────────────────────────────────────────
build-base:
	docker compose build base

# ── Buildroot ─────────────────────────────────────────────────────────────────
buildroot-shell: check-sdk build-base
	docker compose build buildroot
	SDK_PATH="$(SDK_PATH)" HOST_DC695F_PATH="$(HOST_DC695F_PATH)" \
		docker compose run --rm buildroot bash

buildroot-build: check-sdk build-base
	docker compose build buildroot
	SDK_PATH="$(SDK_PATH)" HOST_DC695F_PATH="$(HOST_DC695F_PATH)" \
		docker compose run --rm --name dc695f-buildroot buildroot \
		bash /opt/dc695f-scripts/build-buildroot.sh

buildroot: buildroot-build

# ── Debian (Bookworm) ─────────────────────────────────────────────────────────
debian-shell: check-sdk build-base
	docker compose build debian
	SDK_PATH="$(SDK_PATH)" HOST_DC695F_PATH="$(HOST_DC695F_PATH)" \
		docker compose run --rm debian bash

debian-build: check-sdk build-base
	docker compose build debian
	SDK_PATH="$(SDK_PATH)" HOST_DC695F_PATH="$(HOST_DC695F_PATH)" \
		docker compose run --rm --name dc695f-debian debian \
		bash /opt/dc695f-scripts/build-debian.sh

debian: debian-build

# ── Ubuntu (Jammy) ────────────────────────────────────────────────────────────
ubuntu-shell: check-sdk build-base
	docker compose build ubuntu
	SDK_PATH="$(SDK_PATH)" HOST_DC695F_PATH="$(HOST_DC695F_PATH)" \
		docker compose run --rm ubuntu bash

ubuntu-build: check-sdk build-base
	docker compose build ubuntu
	SDK_PATH="$(SDK_PATH)" HOST_DC695F_PATH="$(HOST_DC695F_PATH)" \
		docker compose run --rm --name dc695f-ubuntu ubuntu \
		bash /opt/dc695f-scripts/build-ubuntu.sh

ubuntu: ubuntu-build

# ── Yocto ─────────────────────────────────────────────────────────────────────
yocto-shell: check-sdk build-base
	docker compose build yocto
	SDK_PATH="$(SDK_PATH)" HOST_DC695F_PATH="$(HOST_DC695F_PATH)" \
		docker compose run --rm yocto bash

yocto-build: check-sdk build-base
	docker compose build yocto
	SDK_PATH="$(SDK_PATH)" HOST_DC695F_PATH="$(HOST_DC695F_PATH)" \
		docker compose run --rm --name dc695f-yocto yocto \
		bash /opt/dc695f-scripts/build-yocto.sh

yocto: yocto-build

# ── Help ──────────────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "DC695-F SDK Docker Build Environment"
	@echo "====================================="
	@echo ""
	@echo "Usage: make [SDK_PATH=<path>] <target>"
	@echo ""
	@echo "  SDK_PATH defaults to: ../SDK/rk3576_linux6.1_sdk_stan_rkr6_250121"
	@echo ""
	@echo "Targets:"
	@echo "  build-base        Build the shared base Docker image"
	@echo ""
	@echo "  buildroot         Build Buildroot image + start build (tmux)"
	@echo "  buildroot-shell   Build Buildroot image, drop into bash"
	@echo ""
	@echo "  debian            Build Debian (Bookworm) image + start build (tmux)"
	@echo "  debian-shell      Build Debian image, drop into bash"
	@echo ""
	@echo "  ubuntu            Build Ubuntu (Jammy) image + start build (tmux)"
	@echo "  ubuntu-shell      Build Ubuntu image, drop into bash"
	@echo ""
	@echo "  yocto             Build Yocto image + start build (tmux)"
	@echo "  yocto-shell       Build Yocto image, drop into bash"
	@echo ""
	@echo "Reattach to a running build:"
	@echo "  docker exec -it dc695f-buildroot  tmux attach -t buildroot-build"
	@echo "  docker exec -it dc695f-debian     tmux attach -t debian-build"
	@echo "  docker exec -it dc695f-ubuntu     tmux attach -t ubuntu-build"
	@echo "  docker exec -it dc695f-yocto      tmux attach -t yocto-build"
	@echo ""
