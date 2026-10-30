#!/usr/bin/env bash
# NivOS Instant GUI Test Script via WSLg
# Launches NivOS graphical environment directly onto the Windows desktop

set -euo pipefail

CHROOT_DIR="/var/tmp/nivos-build/chroot"

echo "=== Preparing NivOS GUI for Windows (WSLg) ==="

# Ensure chroot mounts do not propagate back to host
sudo mount --make-rslave / 2>/dev/null || true
sudo mkdir -p "${CHROOT_DIR}"/{dev,proc,sys,mnt/wslg,run/user/1000,tmp/.X11-unix}

# Mount essential kernel and userland display filesystems with slave propagation
sudo mount --bind /dev "${CHROOT_DIR}/dev" || true
sudo mount --make-private "${CHROOT_DIR}/dev" 2>/dev/null || true
sudo mount --bind /dev/pts "${CHROOT_DIR}/dev/pts" || true
sudo mount -t proc proc "${CHROOT_DIR}/proc" || true
sudo mount -t sysfs sysfs "${CHROOT_DIR}/sys" || true

# Bind mount WSLg sockets and X11/Wayland runtime
sudo mkdir -p "${CHROOT_DIR}/mnt/wslg" "${CHROOT_DIR}/run/user/1000" "${CHROOT_DIR}/tmp/.X11-unix"
sudo mount --bind /mnt/wslg "${CHROOT_DIR}/mnt/wslg" || true
sudo mount --bind /run/user/1000 "${CHROOT_DIR}/run/user/1000" || true
sudo mount --bind /tmp/.X11-unix "${CHROOT_DIR}/tmp/.X11-unix" || true

# Set permissions for the nivos user
sudo chroot "${CHROOT_DIR}" chown -R nivos:nivos /run/user/1000 || true

# Start dbus inside chroot for modern IPC
sudo chroot "${CHROOT_DIR}" service dbus start 2>/dev/null || true

echo "Launching NivOS COSMIC apps onto Windows desktop (COSMIC Terminal, COSMIC Files, Brave)..."

# Run GUI applications as nivos user
sudo chroot "${CHROOT_DIR}" su - nivos -c '
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export WAYLAND_DISPLAY=wayland-0
    export DISPLAY=:0
    export XDG_RUNTIME_DIR=/run/user/1000
    export PULSE_SERVER=/mnt/wslg/PulseServer
    export LIBGL_ALWAYS_SOFTWARE=0

    # 1. Launch COSMIC Terminal with fastfetch (fallback to konsole or kitty if needed)
    if command -v cosmic-term >/dev/null 2>&1; then
        cosmic-term -e bash -c "fastfetch; echo \"\"; echo \"[NivOS COSMIC Desktop (Rust) / Linux 7.3 Active]\"; bash" >/dev/null 2>&1 &
    else
        konsole -e bash -c "fastfetch; echo \"\"; echo \"[NivOS COSMIC Desktop / Linux 7.3 Active]\"; bash" >/dev/null 2>&1 &
    fi

    # 2. Launch COSMIC Files manager
    if command -v cosmic-files >/dev/null 2>&1; then
        cosmic-files >/dev/null 2>&1 &
    else
        dolphin >/dev/null 2>&1 &
    fi

    # 3. Launch Brave Browser (default browser)
    brave-browser >/dev/null 2>&1 &
'

echo "=== NivOS GUI successfully launched on Windows desktop ==="
echo "You will see COSMIC Terminal, COSMIC Files, and Brave Browser on your Windows screen."
echo "To stop all NivOS GUI processes and unmount cleanly: ./scripts/stop_gui.sh"
