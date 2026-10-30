#!/usr/bin/env bash
# NivOS Stop GUI & Cleanup Mounts
set -euo pipefail

CHROOT_DIR="/var/tmp/nivos-build/chroot"

echo "=== Stopping NivOS GUI processes ==="
pkill -f cosmic-term 2>/dev/null || true
pkill -f cosmic-files 2>/dev/null || true
pkill -f brave 2>/dev/null || true
pkill -f nivos-desktop-overlay 2>/dev/null || true

echo "=== Unmounting NivOS test mounts ==="
sudo umount -lf "${CHROOT_DIR}/tmp/.X11-unix" 2>/dev/null || true
sudo umount -lf "${CHROOT_DIR}/run/user/1000" 2>/dev/null || true
sudo umount -lf "${CHROOT_DIR}/mnt/wslg" 2>/dev/null || true
sudo umount -lf "${CHROOT_DIR}/proc" 2>/dev/null || true
sudo umount -lf "${CHROOT_DIR}/sys" 2>/dev/null || true
sudo umount -lf "${CHROOT_DIR}/dev/pts" 2>/dev/null || true
sudo umount -lf "${CHROOT_DIR}/dev" 2>/dev/null || true

echo "=== Cleaned up all GUI mounts ==="
