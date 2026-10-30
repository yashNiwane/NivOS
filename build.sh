#!/usr/bin/env bash
# NivOS Master Build Script
# Orchestrates Kernel 7.3 build, Debian Sid rootfs, Hyprland desktop, and output artifacts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "${SCRIPT_DIR}/scripts/"*.sh

usage() {
    cat << EOF
Usage: $0 [OPTION]

Options:
  --all        Execute all stages (Kernel -> Rootfs -> Live ISO -> WSL Package)
  --kernel     Stage 1: Fetch and build Linux 7.3 Kernel
  --rootfs     Stage 2: Assemble Debian Sid Rootfs with Hyprland & Waybar
  --iso        Stage 3: Package Live Hybrid Bootable ISO
  --wsl        Stage 4: Package WSL2 Importable Rootfs
  --help       Display this help message
EOF
    exit 1
}

TARGET="${1:---all}"

case "${TARGET}" in
    --all)
        echo ">>> Starting full NivOS build pipeline..."
        "${SCRIPT_DIR}/scripts/01_fetch_and_build_kernel.sh"
        "${SCRIPT_DIR}/scripts/02_create_rootfs.sh"
        "${SCRIPT_DIR}/scripts/03_create_iso.sh"
        "${SCRIPT_DIR}/scripts/04_create_wsl_package.sh"
        ;;
    --kernel)
        "${SCRIPT_DIR}/scripts/01_fetch_and_build_kernel.sh"
        ;;
    --rootfs)
        "${SCRIPT_DIR}/scripts/02_create_rootfs.sh"
        ;;
    --iso)
        "${SCRIPT_DIR}/scripts/03_create_iso.sh"
        ;;
    --wsl)
        "${SCRIPT_DIR}/scripts/04_create_wsl_package.sh"
        ;;
    --help|-h)
        usage
        ;;
    *)
        echo "Unknown option: ${TARGET}"
        usage
        ;;
esac

echo ">>> NivOS pipeline completed."
