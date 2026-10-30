#!/usr/bin/env bash
# NivOS Stage 3: Generate Bootable Hybrid UEFI/BIOS Live ISO
# Adheres to principle-prove-it-works & principle-make-operations-idempotent

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="/var/tmp/nivos-build"
CHROOT_DIR="${BUILD_DIR}/chroot"
ISO_STAGING="${BUILD_DIR}/iso-staging"
OUT_DIR="${ROOT_DIR}/out"

echo "=== Stage 3: Packaging Live Bootable Hybrid ISO ==="

mkdir -p "${ISO_STAGING}/live" "${ISO_STAGING}/boot/grub" "${OUT_DIR}"

# 1. Create compressed SquashFS rootfs
echo "Compressing chroot filesystem into SquashFS (zstd)..."
rm -f "${ISO_STAGING}/live/filesystem.squashfs"
sudo mksquashfs "${CHROOT_DIR}" "${ISO_STAGING}/live/filesystem.squashfs" \
    -comp zstd \
    -noappend \
    -wildcards \
    -e "proc/*" "sys/*" "dev/*" "run/*" "tmp/*"

# 2. Extract Kernel and Initramfs for Live Boot
echo "Locating kernel and initramfs binaries..."
VMLINUZ=$(ls -1t "${CHROOT_DIR}"/boot/vmlinuz* | head -n 1)
INITRD=$(ls -1t "${CHROOT_DIR}"/boot/initrd* | head -n 1)

if [ -z "${VMLINUZ}" ] || [ -z "${INITRD}" ]; then
    echo "ERROR: Kernel vmlinuz or initrd not found in ${CHROOT_DIR}/boot"
    exit 1
fi

sudo cp "${VMLINUZ}" "${ISO_STAGING}/live/vmlinuz"
sudo cp "${INITRD}" "${ISO_STAGING}/live/initrd.img"
sudo chmod 644 "${ISO_STAGING}/live/vmlinuz" "${ISO_STAGING}/live/initrd.img"

# 3. Generate GRUB Boot Configuration
cat << 'EOF' > "${ISO_STAGING}/boot/grub/grub.cfg"
set default="0"
set timeout=5

insmod all_video
insmod gfxterm
terminal_output gfxterm

set color_normal=light-gray/black
set color_highlight=black/cyan
set menu_color_normal=light-gray/black
set menu_color_highlight=black/cyan

menuentry "NivOS 1.0 (Live - COSMIC Desktop / Linux 7.3)" {
    linux /live/vmlinuz boot=live components
    initrd /live/initrd.img
}

menuentry "NivOS 1.0 (Safe Graphics / Fallback Framebuffer)" {
    linux /live/vmlinuz boot=live components nomodeset
    initrd /live/initrd.img
}
EOF

# 4. Generate Hybrid ISO with grub-mkrescue
ISO_TARGET="${OUT_DIR}/NivOS-7.3-x86_64.iso"
echo "Generating bootable hybrid ISO: ${ISO_TARGET}..."
grub-mkrescue -o "${ISO_TARGET}" "${ISO_STAGING}" -- -volid "NIVOS_LIVE"

echo "=== ISO Generated Successfully: ${ISO_TARGET} ($(du -h "${ISO_TARGET}" | cut -f1)) ==="
