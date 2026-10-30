#!/usr/bin/env bash
# NivOS Stage 1: Fetch and build Linux 7.3 Kernel
# Adheres to principle-make-operations-idempotent & principle-model-the-domain

set -euo pipefail

BUILD_DIR="/var/tmp/nivos-build"
SRC_DIR="${BUILD_DIR}/sources"
KERNEL_VER="7.3"
TARBALL="linux-${KERNEL_VER}.tar.xz"
TARBALL_URL="https://cdn.kernel.org/pub/linux/kernel/v7.x/${TARBALL}"
DEB_OUT="${BUILD_DIR}/packages"

echo "=== Stage 1: Linux ${KERNEL_VER} Kernel Pipeline ==="

mkdir -p "${SRC_DIR}" "${DEB_OUT}"

# 1. Download tarball idempotently
if [ ! -f "${SRC_DIR}/${TARBALL}" ]; then
    echo "Downloading Linux ${KERNEL_VER} source..."
    curl -fL -o "${SRC_DIR}/${TARBALL}" "${TARBALL_URL}"
else
    echo "Using cached kernel tarball: ${SRC_DIR}/${TARBALL}"
fi

# 2. Extract source tree idempotently
KERNEL_WORK="${BUILD_DIR}/linux-${KERNEL_VER}"
if [ ! -d "${KERNEL_WORK}" ]; then
    echo "Extracting ${TARBALL} to ${BUILD_DIR}..."
    tar -xf "${SRC_DIR}/${TARBALL}" -C "${BUILD_DIR}"
fi

cd "${KERNEL_WORK}"

# 3. Configure kernel with p-stack desktop optimizations
if [ ! -f .config ]; then
    echo "Generating base defconfig..."
    make defconfig

    echo "Applying NivOS p-stack optimizations (low latency, ZRAM, Wayland KMS/DRM)..."
    ./scripts/config --enable CONFIG_PREEMPT_DYNAMIC
    ./scripts/config --enable CONFIG_ZRAM
    ./scripts/config --enable CONFIG_ZRAM_DEF_COMP_ZSTD
    ./scripts/config --enable CONFIG_SQUASHFS
    ./scripts/config --enable CONFIG_SQUASHFS_ZSTD
    ./scripts/config --enable CONFIG_OVERLAY_FS
    ./scripts/config --enable CONFIG_EFI_STUB
    ./scripts/config --enable CONFIG_DRM_VIRTIO_GPU
    ./scripts/config --enable CONFIG_DRM_AMDGPU
    ./scripts/config --enable CONFIG_DRM_I915
    ./scripts/config --enable CONFIG_DRM_NOUVEAU
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
    ./scripts/config --enable CONFIG_TRANSPARENT_HUGEPAGE
    ./scripts/config --enable CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
    ./scripts/config --enable CONFIG_NUMA_BALANCING
    ./scripts/config --enable CONFIG_CPU_FREQ_GOV_PERFORMANCE
    ./scripts/config --enable CONFIG_CPU_FREQ_GOV_SCHEDUTIL
    ./scripts/config --enable CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL
    ./scripts/config --enable CONFIG_X86_AMD_PSTATE
    ./scripts/config --enable CONFIG_X86_INTEL_PSTATE
    ./scripts/config --disable CONFIG_DEBUG_INFO
    ./scripts/config --disable CONFIG_DEBUG_INFO_BTF
    ./scripts/config --disable CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
    ./scripts/config --set-str CONFIG_LOCALVERSION "-nivos-7.3"

    make olddefconfig
fi

# 4. Compile and package .deb
echo "Compiling Linux ${KERNEL_VER} kernel (threads: $(nproc))..."
make -j"$(nproc)" bindeb-pkg DPKG_FLAGS="-d" LOCALVERSION="-nivos-7.3"

# Move generated debs to package cache
mv ../linux-image-${KERNEL_VER}*.deb "${DEB_OUT}/" || true
mv ../linux-headers-${KERNEL_VER}*.deb "${DEB_OUT}/" || true

echo "=== Linux ${KERNEL_VER} Kernel Packages Built Successfully in ${DEB_OUT} ==="
