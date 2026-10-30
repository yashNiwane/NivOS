#!/usr/bin/env bash
# NivOS Incremental Kernel Rebuild for VirtualBox, VMware & Generic VMs
# Adds DRM_VMWGFX, DRM_VBOXVIDEO, DRM_BOCHS, DRM_SIMPLEDRM and updates the ISO
set -euo pipefail

BUILD_DIR="/var/tmp/nivos-build"
KERNEL_WORK="${BUILD_DIR}/linux-7.3"
CHROOT_DIR="${BUILD_DIR}/chroot"
DEB_OUT="${BUILD_DIR}/packages"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== 1. Updating Kernel Configuration for VirtualBox & Hypervisors ==="
cd "${KERNEL_WORK}"

./scripts/config --enable CONFIG_DRM_VMWGFX
./scripts/config --enable CONFIG_DRM_VBOXVIDEO
./scripts/config --enable CONFIG_DRM_BOCHS
./scripts/config --enable CONFIG_DRM_SIMPLEDRM
./scripts/config --enable CONFIG_DRM_FBDEV_EMULATION
./scripts/config --enable CONFIG_SYSFB_SIMPLEFB
./scripts/config --enable CONFIG_FB
./scripts/config --enable CONFIG_FRAMEBUFFER_CONSOLE
./scripts/config --enable CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY
./scripts/config --enable CONFIG_FONT_8x16

make olddefconfig

echo "=== 2. Compiling Incremental Kernel Packages (threads: $(nproc)) ==="
make -j"$(nproc)" bindeb-pkg DPKG_FLAGS="-d" LOCALVERSION="-nivos-7.3"

# Move generated debs
mv ../linux-image-7.3*.deb "${DEB_OUT}/" || true
mv ../linux-headers-7.3*.deb "${DEB_OUT}/" || true
mkdir -p "${ROOT_DIR}/config/kernel"
cp "${DEB_OUT}"/*.deb "${ROOT_DIR}/config/kernel/"

echo "=== 3. Updating Kernel in Chroot ==="
cleanup_mounts() {
    sudo umount -lf "${CHROOT_DIR}/proc" 2>/dev/null || true
    sudo umount -lf "${CHROOT_DIR}/sys" 2>/dev/null || true
    sudo umount -lf "${CHROOT_DIR}/dev/pts" 2>/dev/null || true
    sudo umount -lf "${CHROOT_DIR}/dev" 2>/dev/null || true
}
trap cleanup_mounts EXIT

sudo mount --bind /dev "${CHROOT_DIR}/dev"
sudo mount --make-private "${CHROOT_DIR}/dev"
sudo mount --bind /dev/pts "${CHROOT_DIR}/dev/pts"
sudo mount -t proc proc "${CHROOT_DIR}/proc"
sudo mount -t sysfs sysfs "${CHROOT_DIR}/sys"

sudo cp "${DEB_OUT}"/*.deb "${CHROOT_DIR}/tmp/"
sudo chroot "${CHROOT_DIR}" bash -c "dpkg -i /tmp/*.deb"
sudo chroot "${CHROOT_DIR}" bash -c "update-initramfs -u -k all"
sudo rm -f "${CHROOT_DIR}/tmp/"*.deb

cleanup_mounts
trap - EXIT

echo "=== 4. Re-packaging Bootable Live Hybrid ISO ==="
"${ROOT_DIR}/scripts/03_create_iso.sh"

echo "=== 5. Re-packaging WSL2 Rootfs Archive ==="
"${ROOT_DIR}/scripts/04_create_wsl_package.sh"

echo "=== Complete! New ISO and Rootfs generated with full VirtualBox and VMware support ==="
