#!/usr/bin/env bash
# NivOS Stage 2: Assemble Debian Sid Rootfs with Hyprland & Linux 7.3
# Adheres to principle-foundational-thinking and principle-make-operations-idempotent

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="/var/tmp/nivos-build"
CHROOT_DIR="${BUILD_DIR}/chroot"
DEB_CACHE="${BUILD_DIR}/packages"

echo "=== Stage 2: Debootstrap & Userland Setup ==="

# 1. Debootstrap Debian Sid base idempotently
if [ ! -f "${CHROOT_DIR}/bin/bash" ]; then
    echo "Running debootstrap for Debian Sid..."
    mkdir -p "${CHROOT_DIR}"
    sudo debootstrap --arch=amd64 --keyring=/usr/share/keyrings/debian-archive-keyring.pgp sid "${CHROOT_DIR}" http://deb.debian.org/debian/
else
    echo "Using existing debootstrap base in ${CHROOT_DIR}"
fi

# 2. Bind mount kernel filesystems
cleanup() {
    echo "Unmounting chroot filesystems..."
    sudo umount -lf "${CHROOT_DIR}/proc" 2>/dev/null || true
    sudo umount -lf "${CHROOT_DIR}/sys" 2>/dev/null || true
    sudo umount -lf "${CHROOT_DIR}/dev/pts" 2>/dev/null || true
    sudo umount -lf "${CHROOT_DIR}/dev" 2>/dev/null || true
}
trap cleanup EXIT

sudo mount --bind /dev "${CHROOT_DIR}/dev"
sudo mount --bind /dev/pts "${CHROOT_DIR}/dev/pts"
sudo mount -t proc proc "${CHROOT_DIR}/proc"
sudo mount -t sysfs sysfs "${CHROOT_DIR}/sys"

# Configure DNS inside chroot
sudo cp /etc/resolv.conf "${CHROOT_DIR}/etc/resolv.conf"

# 3. Configure Apt Sources for Sid
cat << 'EOF' | sudo tee "${CHROOT_DIR}/etc/apt/sources.list"
deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
EOF

# 4. Install Packages
echo "Updating chroot apt and installing package lists..."
sudo chroot "${CHROOT_DIR}" apt-get update
PACKAGES=$(grep -v '^#' "${ROOT_DIR}/config/packages.list" | grep -v '^$' | tr '\n' ' ')
sudo chroot "${CHROOT_DIR}" env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" ${PACKAGES}

# 5. Install Linux 7.3 Kernel Packages if present
if ls "${DEB_CACHE}"/linux-image-*.deb 1>/dev/null 2>&1; then
    echo "Installing custom Linux 7.3 Kernel into rootfs..."
    sudo cp "${DEB_CACHE}"/*.deb "${CHROOT_DIR}/tmp/"
    sudo chroot "${CHROOT_DIR}" bash -c "dpkg -i /tmp/*.deb || apt-get install -fy"
    sudo chroot "${CHROOT_DIR}" bash -c "update-initramfs -c -k all" || true
    sudo rm -f "${CHROOT_DIR}/tmp/"*.deb
fi

# Configure Locale
sudo chroot "${CHROOT_DIR}" bash -c "echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen" || true
echo "LANG=en_US.UTF-8" | sudo tee "${CHROOT_DIR}/etc/default/locale"

# 6. Apply NivOS Branding & Metadata
cat << 'EOF' | sudo tee "${CHROOT_DIR}/etc/os-release"
NAME="NivOS"
PRETTY_NAME="NivOS 1.0 (Debian Sid / Linux 7.3)"
ID=nivos
ID_LIKE=debian
VERSION="1.0"
HOME_URL="https://github.com/YashN/NivOS"
EOF

echo "nivos" | sudo tee "${CHROOT_DIR}/etc/hostname"
cat << 'EOF' | sudo tee "${CHROOT_DIR}/etc/hosts"
127.0.0.1   localhost
127.0.1.1   nivos
::1         localhost ip6-localhost ip6-loopback
EOF

# 7. Setup Default User & Privileges
sudo chroot "${CHROOT_DIR}" bash -c "
if ! id -u nivos >/dev/null 2>&1; then
    groupadd -f nopasswdlogin
    useradd -m -s /bin/bash -G sudo,video,audio,render,input,nopasswdlogin nivos
    echo 'nivos:nivos' | chpasswd -c SHA512
    echo 'root:root' | chpasswd -c SHA512
fi
"

# 8. Deploy COSMIC Desktop Environment
if [ -f "${ROOT_DIR}/scripts/install_cosmic.sh" ]; then
    echo "Running install_cosmic.sh..."
    "${ROOT_DIR}/scripts/install_cosmic.sh"
fi

# 9. Configure SDDM & ZRAM
sudo mkdir -p "${CHROOT_DIR}/etc/sddm.conf.d"
sudo cp "${ROOT_DIR}/config/sddm/sddm.conf" "${CHROOT_DIR}/etc/sddm.conf.d/nivos.conf"
sudo cp "${ROOT_DIR}/config/systemd/zram.conf" "${CHROOT_DIR}/etc/default/zramswap" || true

# 10. Enable Essential Services
sudo chroot "${CHROOT_DIR}" systemctl enable sddm.service NetworkManager.service || true

# 11. Clean Up Package Cache
sudo chroot "${CHROOT_DIR}" apt-get clean
sudo rm -rf "${CHROOT_DIR}/var/lib/apt/lists/*"

echo "=== Stage 2 Complete: Rootfs Assembled Successfully ==="
