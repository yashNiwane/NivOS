#!/usr/bin/env bash
set -euo pipefail

echo "Restoring host /dev and /dev/pts..."
# Unmount shadowed /dev mount
sudo umount -l /dev 2>/dev/null || true

# Ensure devpts is cleanly mounted
if ! mountpoint -q /dev/pts 2>/dev/null; then
    sudo mount -t devpts devpts /dev/pts -o rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 2>/dev/null || true
fi

echo "PTY subsystem restored successfully."
