#!/usr/bin/env bash
# NivOS COSMIC Desktop Installation & Configuration Script
# Adheres to principle-prove-it-works & principle-make-operations-idempotent

set -euo pipefail

CHROOT_DIR="/var/tmp/nivos-build/chroot"
COSMIC_DEB_DIR="/var/tmp/nivos-build/cosmic-debs"

echo "=== Installing COSMIC Desktop Environment into Rootfs ==="

# 1. Clean mounts on exit
cleanup() {
    echo "Unmounting chroot filesystems..."
    sudo umount -lf "${CHROOT_DIR}/proc" 2>/dev/null || true
    sudo umount -lf "${CHROOT_DIR}/sys" 2>/dev/null || true
    sudo umount -lf "${CHROOT_DIR}/dev/pts" 2>/dev/null || true
    sudo umount -lf "${CHROOT_DIR}/dev" 2>/dev/null || true
}
trap cleanup EXIT

# 2. Bind mount required kernel filesystems
sudo mount --bind /dev "${CHROOT_DIR}/dev"
sudo mount --make-private "${CHROOT_DIR}/dev" 2>/dev/null || true
sudo mount --bind /dev/pts "${CHROOT_DIR}/dev/pts"
sudo mount -t proc proc "${CHROOT_DIR}/proc"
sudo mount -t sysfs sysfs "${CHROOT_DIR}/sys"

# Copy DNS config
sudo cp /etc/resolv.conf "${CHROOT_DIR}/etc/resolv.conf"

# 3. Copy deb packages into chroot tmp
sudo mkdir -p "${CHROOT_DIR}/tmp/cosmic-debs"
sudo cp "${COSMIC_DEB_DIR}"/*.deb "${CHROOT_DIR}/tmp/cosmic-debs/"

# 4. Install prerequisites and external dependencies inside chroot
echo "Updating apt and installing base display/Wayland dependencies..."
sudo chroot "${CHROOT_DIR}" bash -c "
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends \
        libgl1-mesa-dri \
        mesa-vulkan-drivers \
        xwayland \
        flatpak \
        xdg-desktop-portal \
        libgbm1 \
        libseat1 \
        libinput10 \
        libxkbcommon0 \
        fonts-noto-color-emoji \
        adwaita-icon-theme \
        greetd \
        fonts-open-sans \
        gnome-keyring \
        switcheroo-control \
        accountsservice \
        iso-codes \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        libheif1 \
        dconf-gsettings-backend \
        libsecret-1-0 \
        network-manager-openvpn \
        network-manager-openvpn-gnome \
        nm-connection-editor \
        pulseaudio-utils \
        qalc \
        fd-find

    echo 'Installing COSMIC deb packages...'
    dpkg -i /tmp/cosmic-debs/*.deb || apt-get install -fy --no-install-recommends -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\"

    rm -rf /tmp/cosmic-debs
"

# 5. Verify Wayland session file
echo "Verifying COSMIC Wayland session..."
if [ -f "${CHROOT_DIR}/usr/share/wayland-sessions/cosmic.desktop" ]; then
    echo "Found /usr/share/wayland-sessions/cosmic.desktop"
    # Create symlink cosmic -> cosmic.desktop for display manager compatibility
    sudo ln -sf cosmic.desktop "${CHROOT_DIR}/usr/share/wayland-sessions/cosmic"
else
    echo "ERROR: cosmic.desktop not found in /usr/share/wayland-sessions/"
    exit 1
fi

# 6. Ensure SDDM autologin is configured for cosmic.desktop
echo "Ensuring SDDM autologin to COSMIC session..."
sudo mkdir -p "${CHROOT_DIR}/etc/sddm.conf.d"
cat << 'EOF' | sudo tee "${CHROOT_DIR}/etc/sddm.conf"
[General]
InputMethod=
Numlock=none

[Theme]
Current=breeze
CursorTheme=breeze_cursors

[Wayland]
EnableHiDPI=true
SessionDir=/usr/share/wayland-sessions

[Autologin]
User=nivos
Session=cosmic.desktop
Relogin=false

[Users]
RememberLastSession=true
RememberLastUser=true
DefaultPath=/usr/local/bin:/usr/bin:/bin
EOF

sudo cp "${CHROOT_DIR}/etc/sddm.conf" "${CHROOT_DIR}/etc/sddm.conf.d/nivos.conf"

# 7. Enforce Brave as Default Browser in COSMIC / XDG
echo "Configuring Brave as default browser..."
sudo mkdir -p "${CHROOT_DIR}/etc/xdg"
cat << 'EOF' | sudo tee "${CHROOT_DIR}/etc/xdg/mimeapps.list"
[Default Applications]
text/html=brave-browser.desktop
x-scheme-handler/http=brave-browser.desktop
x-scheme-handler/https=brave-browser.desktop
x-scheme-handler/about=brave-browser.desktop
x-scheme-handler/unknown=brave-browser.desktop
EOF

# Ensure user directory ownership
sudo chroot "${CHROOT_DIR}" chown -R nivos:nivos /home/nivos

# 8. Clean up apt cache
sudo chroot "${CHROOT_DIR}" apt-get clean
sudo rm -rf "${CHROOT_DIR}/var/lib/apt/lists/*"

echo "=== COSMIC Desktop Successfully Installed and Configured ==="
