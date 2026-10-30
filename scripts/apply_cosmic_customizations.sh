#!/usr/bin/env bash
# scripts/apply_cosmic_customizations.sh
# Applies bespoke NivOS styling, theming, wallpapers, and native COSMIC configuration
# without any external/third-party navigation overlays.
set -euo pipefail

CHROOT_DIR="${1:-/var/tmp/nivos-build/chroot}"

if [ ! -d "$CHROOT_DIR" ]; then
    echo "Error: chroot directory $CHROOT_DIR not found!" >&2
    exit 1
fi

echo "==> Applying NivOS Bespoke Customizations to chroot: $CHROOT_DIR"

# 1. Install Default NivOS Wallpaper
echo "--> Installing default NivOS wallpaper..."
mkdir -p "$CHROOT_DIR/usr/share/backgrounds/nivos"
mkdir -p "$CHROOT_DIR/usr/share/backgrounds/cosmic"

if [ -f "config/wallpapers/default-wallpaper.png" ]; then
    cp config/wallpapers/default-wallpaper.png "$CHROOT_DIR/usr/share/backgrounds/nivos/default-wallpaper.png"
    cp config/wallpapers/default-wallpaper.png "$CHROOT_DIR/usr/share/backgrounds/nivos/nivos-cyber-aurora.png"
    cp config/wallpapers/default-wallpaper.png "$CHROOT_DIR/usr/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a.jpg"
elif [ -f "Serene Pastel Mountain Lake at Sunrise.png" ]; then
    cp "Serene Pastel Mountain Lake at Sunrise.png" "$CHROOT_DIR/usr/share/backgrounds/nivos/default-wallpaper.png"
    cp "Serene Pastel Mountain Lake at Sunrise.png" "$CHROOT_DIR/usr/share/backgrounds/nivos/nivos-cyber-aurora.png"
    cp "Serene Pastel Mountain Lake at Sunrise.png" "$CHROOT_DIR/usr/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a.jpg"
else
    python3 scripts/generate_wallpaper.py /var/tmp/nivos-cyber-aurora.png
    cp /var/tmp/nivos-cyber-aurora.png "$CHROOT_DIR/usr/share/backgrounds/nivos/default-wallpaper.png"
    cp /var/tmp/nivos-cyber-aurora.png "$CHROOT_DIR/usr/share/backgrounds/nivos/nivos-cyber-aurora.png"
    cp /var/tmp/nivos-cyber-aurora.png "$CHROOT_DIR/usr/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a.jpg"
fi
chmod 644 "$CHROOT_DIR/usr/share/backgrounds/nivos/"*
chmod 644 "$CHROOT_DIR/usr/share/backgrounds/cosmic/"*

# 1.1 Install Colloid Icon Theme
if [ ! -d "$CHROOT_DIR/usr/share/icons/Colloid-Dark" ]; then
    echo "--> Installing Colloid icon theme..."
    if [ -f "config/icons/Colloid-icon-theme.tar.xz" ]; then
        tar -xf config/icons/Colloid-icon-theme.tar.xz -C /tmp/
        /tmp/Colloid-icon-theme/install.sh -d "$CHROOT_DIR/usr/share/icons"
    elif [ -d "/tmp/Colloid-icon-theme" ]; then
        /tmp/Colloid-icon-theme/install.sh -d "$CHROOT_DIR/usr/share/icons"
    else
        echo "--> Fetching Colloid icon theme from upstream..."
        git clone --depth 1 https://github.com/vinceliuice/Colloid-icon-theme /tmp/Colloid-icon-theme || true
        if [ -f /tmp/Colloid-icon-theme/install.sh ]; then
            /tmp/Colloid-icon-theme/install.sh -d "$CHROOT_DIR/usr/share/icons"
        fi
    fi
fi

# 1.2 Deploy Bespoke Minimal Vector Icons Matching Reference Design
echo "--> Generating and deploying bespoke minimal icons..."
python3 config/icons/generate_minimal_icons.py
mkdir -p "$CHROOT_DIR/usr/share/icons/hicolor/scalable/apps"
mkdir -p "$CHROOT_DIR/usr/share/icons/Colloid-Dark/apps/scalable"
mkdir -p "$CHROOT_DIR/usr/share/icons/Colloid-Dark/categories/scalable"
mkdir -p "$CHROOT_DIR/usr/share/icons/Pop/scalable/apps"
mkdir -p "$CHROOT_DIR/usr/share/icons/Cosmic/scalable/apps"

mkdir -p "$CHROOT_DIR/usr/share/icons/Colloid-Dark/apps/scalable"
mkdir -p "$CHROOT_DIR/usr/share/icons/Colloid-Light/apps/scalable"
mkdir -p "$CHROOT_DIR/usr/share/icons/hicolor/scalable/apps"

for f in config/icons/minimal/*.svg; do
    basef=$(basename "$f")
    cp "$f" "$CHROOT_DIR/usr/share/icons/Colloid-Dark/apps/scalable/"
    cp "$f" "$CHROOT_DIR/usr/share/icons/Colloid-Light/apps/scalable/"
    cp "$f" "$CHROOT_DIR/usr/share/icons/Colloid-Dark/categories/scalable/" 2>/dev/null || true
    cp "$f" "$CHROOT_DIR/usr/share/icons/hicolor/scalable/apps/"
    cp "$f" "$CHROOT_DIR/usr/share/icons/Pop/scalable/apps/" 2>/dev/null || true
    cp "$f" "$CHROOT_DIR/usr/share/icons/Cosmic/scalable/apps/" 2>/dev/null || true
    
    # Overwrite hicolor resolution tiers
    for sz in 16 22 24 32 48 64 128 256; do
        mkdir -p "$CHROOT_DIR/usr/share/icons/hicolor/${sz}x${sz}/apps"
        rsvg-convert -w "$sz" -h "$sz" "$f" -o "$CHROOT_DIR/usr/share/icons/hicolor/${sz}x${sz}/apps/${basef%.svg}.png" 2>/dev/null || true
        rsvg-convert -w "$sz" -h "$sz" "$f" -o "$CHROOT_DIR/usr/share/icons/hicolor/${sz}x${sz}/apps/$basef" 2>/dev/null || true
    done
done

# Ensure 9-dot grid covers all view-app-grid symbolics
for target in \
    "$CHROOT_DIR/usr/share/icons/Colloid-Dark/actions/symbolic/view-app-grid-symbolic.svg" \
    "$CHROOT_DIR/usr/share/icons/Colloid-Dark/actions/symbolic/xsi-view-app-grid-symbolic.svg" \
    "$CHROOT_DIR/usr/share/icons/Colloid-Light/actions/symbolic/view-app-grid-symbolic.svg" \
    "$CHROOT_DIR/usr/share/icons/Colloid-Light/actions/symbolic/xsi-view-app-grid-symbolic.svg" \
    "$CHROOT_DIR/usr/share/icons/Pop/scalable/apps/view-app-grid-symbolic.svg" \
    "$CHROOT_DIR/usr/share/icons/Pop/scalable/apps/view-app-grid.svg" \
    "$CHROOT_DIR/usr/share/icons/Cosmic/scalable/apps/view-app-grid-symbolic.svg" \
    "$CHROOT_DIR/usr/share/icons/Cosmic/scalable/apps/view-app-grid.svg"; do
    if [ -f "$target" ] || [ -L "$target" ]; then
        cp config/icons/minimal/com.system76.CosmicPanelAppButton.svg "$target"
    fi
done

chroot "$CHROOT_DIR" gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true
chroot "$CHROOT_DIR" gtk-update-icon-cache -f -t /usr/share/icons/Colloid-Dark 2>/dev/null || true
chroot "$CHROOT_DIR" gtk-update-icon-cache -f -t /usr/share/icons/Colloid-Light 2>/dev/null || true

# 2. SDDM Theme & Wallpaper
echo "--> Updating SDDM theme configuration..."
if [ -f "$CHROOT_DIR/usr/share/sddm/themes/breeze/theme.conf" ]; then
    sed -i 's|^background=.*|background=/usr/share/backgrounds/nivos/default-wallpaper.png|' "$CHROOT_DIR/usr/share/sddm/themes/breeze/theme.conf"
    sed -i 's|^color=.*|color=#38bdf8|' "$CHROOT_DIR/usr/share/sddm/themes/breeze/theme.conf"
fi

# 3. Fastfetch & Shell Branding
echo "--> Configuring Fastfetch and shell aesthetics..."
mkdir -p "$CHROOT_DIR/etc/fastfetch"

# Styled ANSI ASCII logo
python3 -c '
cyan = "\033[38;2;56;189;248m"
indigo = "\033[38;2;129;140;248m"
reset = "\033[0m"
lines = [
    f"{cyan}  ███╗   ██╗██╗██╗   ██╗ ██████╗ ███████╗{reset}",
    f"{cyan}  ████╗  ██║██║██║   ██║██╔═══██╗██╔════╝{reset}",
    f"{cyan}  ██╔██╗ ██║██║██║   ██║██║   ██║███████╗{reset}",
    f"{indigo}  ██║╚██╗██║██║╚██╗ ██╔╝██║   ██║╚════██║{reset}",
    f"{indigo}  ██║ ╚████║██║ ╚████╔╝ ╚██████╔╝███████║{reset}",
    f"{indigo}  ╚═╝  ╚═══╝╚═╝  ╚═══╝   ╚═════╝ ╚══════╝{reset}",
]
with open("'$CHROOT_DIR'/etc/fastfetch/nivos.txt", "w") as f:
    f.write("\n".join(lines) + "\n")
'
chmod 644 "$CHROOT_DIR/etc/fastfetch/nivos.txt"

cat > "$CHROOT_DIR/etc/fastfetch/config.jsonc" << 'EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "/etc/fastfetch/nivos.txt",
        "type": "file",
        "padding": {
            "top": 1,
            "right": 3
        }
    },
    "display": {
        "separator": " ❯ "
    },
    "modules": [
        "title",
        "separator",
        {
            "type": "os",
            "key": "OS",
            "keyColor": "cyan"
        },
        {
            "type": "kernel",
            "key": "Kernel",
            "keyColor": "cyan"
        },
        {
            "type": "de",
            "key": "Desktop",
            "keyColor": "cyan"
        },
        {
            "type": "wm",
            "key": "Compositor",
            "keyColor": "cyan"
        },
        {
            "type": "theme",
            "key": "Theme",
            "keyColor": "cyan"
        },
        {
            "type": "icons",
            "key": "Icons",
            "keyColor": "cyan"
        },
        {
            "type": "terminal",
            "key": "Terminal",
            "keyColor": "cyan"
        },
        {
            "type": "shell",
            "key": "Shell",
            "keyColor": "cyan"
        },
        {
            "type": "cpu",
            "key": "CPU (AI Engine)",
            "keyColor": "cyan"
        },
        {
            "type": "memory",
            "key": "Memory",
            "keyColor": "cyan"
        },
        "break",
        "colors"
    ]
}
EOF
chmod 644 "$CHROOT_DIR/etc/fastfetch/config.jsonc"

# Bash environment & prompt
for bashrc in "$CHROOT_DIR/etc/skel/.bashrc" "$CHROOT_DIR/home/nivos/.bashrc"; do
    if [ -f "$bashrc" ]; then
        # Remove old prompt block if exists
        sed -i '/# NivOS Cyber Shell Environment/,/# End NivOS Shell/d' "$bashrc"
        cat >> "$bashrc" << 'EOF'

# NivOS Cyber Shell Environment
export PS1='\[\033[01;36m\]┌─[ \[\033[01;34m\]\u@nivos\[\033[01;36m\] ]─[ \[\033[01;32m\]\w\[\033[01;36m\] ]\n└──❯ \[\033[00m\]'

alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias fetch='fastfetch'

if [ -t 1 ] && [ -z "${FASTFETCH_SHOWN:-}" ]; then
    export FASTFETCH_SHOWN=1
    fastfetch
fi
# End NivOS Shell
EOF
    fi
done

# Issue login text
cat > "$CHROOT_DIR/etc/issue" << 'EOF'
NivOS 1.0 (Debian Sid / Linux 7.3 High-Performance AI) \n \l

EOF
cp "$CHROOT_DIR/etc/issue" "$CHROOT_DIR/etc/issue.net"

# 4. COSMIC Systemwide & User Configuration Deployment
echo "--> Deploying COSMIC Desktop Configuration (System, Skel, Home)..."

deploy_cosmic_configs() {
    local target_dir="$1"
    
    # 4.1 Wallpaper
    mkdir -p "$target_dir/com.system76.CosmicBackground/v1"
    cat > "$target_dir/com.system76.CosmicBackground/v1/all" << 'EOF'
(
    output: "all",
    source: Path("/usr/share/backgrounds/nivos/default-wallpaper.png"),
    filter_by_theme: false,
    rotation_frequency: 3600,
    filter_method: Lanczos,
    scaling_mode: Zoom,
    sampling_method: Alphanumeric,
)
EOF

    # 4.2 Dock Favorites (Terminal, Files, Browser, Code, Media, Images, Settings)
    mkdir -p "$target_dir/com.system76.CosmicAppList/v1"
    cat > "$target_dir/com.system76.CosmicAppList/v1/favorites" << 'EOF'
[
    "com.system76.CosmicTerm",
    "com.system76.CosmicFiles",
    "brave-browser",
    "com.system76.CosmicEdit",
    "org.gnome.Showtime",
    "com.system76.CosmicViewer",
    "com.system76.CosmicSettings",
]
EOF

    # 4.3 Left Floating Dock & Top Minimal Bar
    mkdir -p "$target_dir/com.system76.CosmicPanel.Dock/v1"
    echo "Left" > "$target_dir/com.system76.CosmicPanel.Dock/v1/anchor"
    echo "false" > "$target_dir/com.system76.CosmicPanel.Dock/v1/expand_to_edges"
    echo "18" > "$target_dir/com.system76.CosmicPanel.Dock/v1/border_radius"
    echo "0.82" > "$target_dir/com.system76.CosmicPanel.Dock/v1/opacity"
    echo "4" > "$target_dir/com.system76.CosmicPanel.Dock/v1/padding"
    echo "10" > "$target_dir/com.system76.CosmicPanel.Dock/v1/margin"
    echo "M" > "$target_dir/com.system76.CosmicPanel.Dock/v1/size"
    cat > "$target_dir/com.system76.CosmicPanel.Dock/v1/plugins_center" << 'EOF'
Some(["com.system76.CosmicAppList", "com.system76.CosmicPanelAppButton"])
EOF
    echo "None" > "$target_dir/com.system76.CosmicPanel.Dock/v1/plugins_wings"

    mkdir -p "$target_dir/com.system76.CosmicPanel.Panel/v1"
    echo "Top" > "$target_dir/com.system76.CosmicPanel.Panel/v1/anchor"
    echo "true" > "$target_dir/com.system76.CosmicPanel.Panel/v1/expand_to_edges"
    echo "0.0" > "$target_dir/com.system76.CosmicPanel.Panel/v1/opacity"
    echo "0" > "$target_dir/com.system76.CosmicPanel.Panel/v1/border_radius"
    echo "XS" > "$target_dir/com.system76.CosmicPanel.Panel/v1/size"
    cat > "$target_dir/com.system76.CosmicPanel.Panel/v1/plugins_center" << 'EOF'
Some(["com.system76.CosmicPanelLauncherButton"])
EOF
    cat > "$target_dir/com.system76.CosmicPanel.Panel/v1/plugins_wings" << 'EOF'
Some(([], ["com.system76.CosmicAppletNetwork", "com.system76.CosmicAppletBattery", "com.system76.CosmicAppletTime"]))
EOF

    # 4.4 CosmicTk (Icons & Global Dark Theme)
    mkdir -p "$target_dir/com.system76.CosmicTk/v1"
    echo '"Colloid-Dark"' > "$target_dir/com.system76.CosmicTk/v1/icon_theme"
    echo "true" > "$target_dir/com.system76.CosmicTk/v1/apply_theme_global"
    echo "true" > "$target_dir/com.system76.CosmicTk/v1/show_maximize"
    echo "true" > "$target_dir/com.system76.CosmicTk/v1/show_minimize"

    # 4.5 Mode (Always Dark)
    mkdir -p "$target_dir/com.system76.CosmicTheme.Mode/v1"
    echo "true" > "$target_dir/com.system76.CosmicTheme.Mode/v1/is_dark"
    echo "false" > "$target_dir/com.system76.CosmicTheme.Mode/v1/auto_switch"

    # 4.6 Cosmic Dark Theme Builder v2 (Obsidian & Electric Cyan)
    mkdir -p "$target_dir/com.system76.CosmicTheme.Dark.Builder/v2"
    cat > "$target_dir/com.system76.CosmicTheme.Dark.Builder/v2/accent" << 'EOF'
Some((
    red: 0.21960784,
    green: 0.7411765,
    blue: 0.972549,
))
EOF

    cat > "$target_dir/com.system76.CosmicTheme.Dark.Builder/v2/bg_color" << 'EOF'
Some((
    red: 0.03921569,
    green: 0.05882353,
    blue: 0.09803922,
    alpha: 1.0,
))
EOF

    echo "High" > "$target_dir/com.system76.CosmicTheme.Dark.Builder/v2/frosted"
    echo "true" > "$target_dir/com.system76.CosmicTheme.Dark.Builder/v2/frosted_panel"
    echo "true" > "$target_dir/com.system76.CosmicTheme.Dark.Builder/v2/frosted_applets"
    echo "true" > "$target_dir/com.system76.CosmicTheme.Dark.Builder/v2/frosted_windows"
    echo "true" > "$target_dir/com.system76.CosmicTheme.Dark.Builder/v2/frosted_system_interface"

    cat > "$target_dir/com.system76.CosmicTheme.Dark.Builder/v2/corner_radii" << 'EOF'
(
    radius_0: (0.0, 0.0, 0.0, 0.0),
    radius_xs: (4.0, 4.0, 4.0, 4.0),
    radius_s: (8.0, 8.0, 8.0, 8.0),
    radius_m: (12.0, 12.0, 12.0, 12.0),
    radius_l: (20.0, 20.0, 20.0, 20.0),
    radius_xl: (32.0, 32.0, 32.0, 32.0),
)
EOF

    cat > "$target_dir/com.system76.CosmicTheme.Dark.Builder/v2/palette" << 'EOF'
(
    name: "nivos-cyber-dark",
    bright_red: "#F87171FF",
    bright_green: "#4ADE80FF",
    bright_orange: "#FB923CFF",
    gray_1: "#0F172AFF",
    gray_2: "#1E293BFF",
    neutral_0: "#020617FF",
    neutral_1: "#070B14FF",
    neutral_2: "#0F172AFF",
    neutral_3: "#1E293BFF",
    neutral_4: "#334155FF",
    neutral_5: "#475569FF",
    neutral_6: "#64748BFF",
    neutral_7: "#94A3B8FF",
    neutral_8: "#CBD5E1FF",
    neutral_9: "#E2E8F0FF",
    neutral_10: "#F8FAFCFF",
    accent_blue: "#38BDF8FF",
    accent_indigo: "#818CF8FF",
    accent_purple: "#C084FCFF",
    accent_pink: "#F472B6FF",
    accent_red: "#FB7185FF",
    accent_orange: "#FB923CFF",
    accent_yellow: "#FACC15FF",
    accent_green: "#4ADE80FF",
    accent_warm_grey: "#94A3B8FF",
    ext_warm_grey: "#64748BFF",
    ext_orange: "#F97316FF",
    ext_yellow: "#EAB308FF",
    ext_blue: "#0EA5E9FF",
    ext_purple: "#A855F7FF",
    ext_pink: "#EC4899FF",
    ext_indigo: "#6366F1FF",
)
EOF

    # 4.7 Direct Dark Theme v2
    mkdir -p "$target_dir/com.system76.CosmicTheme.Dark/v2"
    echo '"nivos-cyber-dark"' > "$target_dir/com.system76.CosmicTheme.Dark/v2/name"
    echo "High" > "$target_dir/com.system76.CosmicTheme.Dark/v2/frosted"
    echo "true" > "$target_dir/com.system76.CosmicTheme.Dark/v2/frosted_panel"
    echo "true" > "$target_dir/com.system76.CosmicTheme.Dark/v2/frosted_applets"
    echo "true" > "$target_dir/com.system76.CosmicTheme.Dark/v2/frosted_windows"
    echo "true" > "$target_dir/com.system76.CosmicTheme.Dark/v2/frosted_system_interface"

    cat > "$target_dir/com.system76.CosmicTheme.Dark/v2/accent" << 'EOF'
(
    base: "#38BDF8FF",
    hover: "#60A5FAFF",
    pressed: "#0284C7FF",
    selected: "#38BDF8FF",
    selected_text: "#0A0F19FF",
    focus: "#38BDF8FF",
    divider: "#1E293BFF",
    on: "#0A0F19FF",
    disabled: "#38BDF880",
    on_disabled: "#0284C780",
    border: "#38BDF8FF",
    disabled_border: "#38BDF840",
)
EOF

    cat > "$target_dir/com.system76.CosmicTheme.Dark/v2/background" << 'EOF'
(
    base: "#0A0F19FF",
    component: (
        base: "#111827FF",
        hover: "#1F2937FF",
        pressed: "#374151FF",
        selected: "#1E293BFF",
        selected_text: "#38BDF8FF",
        focus: "#38BDF8FF",
        divider: "#1E293B80",
        on: "#F1F5F9FF",
        disabled: "#11182780",
        on_disabled: "#94A3B880",
        border: "#334155FF",
        disabled_border: "#33415560",
    ),
    divider: "#1E293BFF",
    on: "#F8FAFCFF",
    small_widget: "#0F172A80",
)
EOF

    # 4.8 Cosmic Terminal settings
    mkdir -p "$target_dir/com.system76.CosmicTerm/v1"
    echo "0.92" > "$target_dir/com.system76.CosmicTerm/v1/opacity"
    echo "11.0" > "$target_dir/com.system76.CosmicTerm/v1/font_size"
    echo "true" > "$target_dir/com.system76.CosmicTerm/v1/show_headerbar"
}

# Deploy to system defaults
deploy_cosmic_configs "$CHROOT_DIR/usr/share/cosmic"
deploy_cosmic_configs "$CHROOT_DIR/etc/cosmic"
deploy_cosmic_configs "$CHROOT_DIR/etc/skel/.config/cosmic"
deploy_cosmic_configs "$CHROOT_DIR/home/nivos/.config/cosmic"

# 5. GTK 3 & 4 dark settings
for user_cfg in "$CHROOT_DIR/etc/skel/.config" "$CHROOT_DIR/home/nivos/.config"; do
    mkdir -p "$user_cfg/gtk-3.0" "$user_cfg/gtk-4.0"
    cat > "$user_cfg/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name = adw-gtk3-dark
gtk-icon-theme-name = Colloid-Dark
gtk-font-name = DejaVu Sans 10
gtk-cursor-theme-name = breeze_cursors
gtk-application-prefer-dark-theme = 1
EOF
    cp "$user_cfg/gtk-3.0/settings.ini" "$user_cfg/gtk-4.0/settings.ini"
done

# 6. Clean application display names (remove "COSMIC" prefix)
echo "--> Stripping 'COSMIC' prefix from application names..."
python3 scripts/strip_cosmic_app_names.py "$CHROOT_DIR/usr/share/applications"

# 7. Remove any overlay window artifacts (clean production desktop)
echo "--> Ensuring clean desktop without overlay window artifacts..."
rm -f "$CHROOT_DIR/etc/xdg/autostart/nivos-desktop-overlay.desktop"
rm -f "$CHROOT_DIR/etc/systemd/user/graphical-session.target.wants/nivos-desktop-overlay.service"
rm -f "$CHROOT_DIR/etc/systemd/user/nivos-desktop-overlay.service"
rm -f "$CHROOT_DIR/usr/bin/nivos-desktop-overlay"

# Fix user ownership inside chroot
echo "--> Fixing user ownership for /home/nivos..."
# Look up UID/GID of nivos inside chroot
NIVOS_UID=$(grep "^nivos:" "$CHROOT_DIR/etc/passwd" | cut -d: -f3 || echo "1000")
NIVOS_GID=$(grep "^nivos:" "$CHROOT_DIR/etc/passwd" | cut -d: -f4 || echo "1000")
chown -R "$NIVOS_UID:$NIVOS_GID" "$CHROOT_DIR/home/nivos"

# Also replicate to workspace config/cosmic/ for version control
mkdir -p config/cosmic
cp -r "$CHROOT_DIR/etc/skel/.config/cosmic/"* config/cosmic/

echo "==> NivOS Customizations successfully applied!"
