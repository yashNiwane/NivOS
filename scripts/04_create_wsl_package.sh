#!/usr/bin/env bash
# NivOS Stage 4: Generate WSL2 Importable Distro Archive
# Allows instant testing in Windows via `wsl --import NivOS ...`

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="/var/tmp/nivos-build"
CHROOT_DIR="${BUILD_DIR}/chroot"
OUT_DIR="${ROOT_DIR}/out"
TAR_TARGET="${OUT_DIR}/nivos-rootfs.tar.gz"

echo "=== Stage 4: Packaging WSL2 Importable Rootfs ==="

mkdir -p "${OUT_DIR}"

# Create tarball of rootfs, excluding virtual mounts
echo "Compressing rootfs for WSL2 into ${TAR_TARGET}..."
sudo tar --exclude="./dev/*" \
         --exclude="./proc/*" \
         --exclude="./sys/*" \
         --exclude="./tmp/*" \
         --exclude="./run/*" \
         -czf "${TAR_TARGET}" -C "${CHROOT_DIR}" .

echo "=== WSL2 Archive Generated: ${TAR_TARGET} ($(du -h "${TAR_TARGET}" | cut -f1)) ==="
echo "To import into Windows PowerShell:"
echo "wsl --import NivOS C:\\WSL\\NivOS C:\\Users\\YashN\\Desktop\\MyLinux\\out\\nivos-rootfs.tar.gz"
