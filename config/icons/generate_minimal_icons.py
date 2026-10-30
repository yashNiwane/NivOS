#!/usr/bin/env python3
"""
Generate bespoke minimal, modern vector icons matching the reference design:
1. com.system76.CosmicTerm: dark slate squircle with white `>_`
2. com.system76.CosmicFiles: vibrant cyan rounded folder
3. brave-browser: sleek circular flame swirl emblem
4. com.system76.CosmicEdit: modern VS Code blue ribbon emblem
5. org.gnome.Showtime: magenta squircle with white musical notes
6. com.system76.CosmicViewer: purple squircle with white mountain photo
7. com.system76.CosmicSettings: dark charcoal squircle with white gear
8. com.system76.CosmicPanelAppButton & view-app-grid: 9 clean white dots (3x3 grid)
"""

import os

ICONS = {
    "com.system76.CosmicTerm.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <linearGradient id="termBg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#3d4451"/>
      <stop offset="100%" stop-color="#222731"/>
    </linearGradient>
    <linearGradient id="termBorder" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#555f72" stop-opacity="0.6"/>
      <stop offset="100%" stop-color="#2a303d" stop-opacity="0.3"/>
    </linearGradient>
  </defs>
  <!-- Background Squircle -->
  <rect x="8" y="8" width="112" height="112" rx="28" ry="28" fill="url(#termBg)" stroke="url(#termBorder)" stroke-width="2.5"/>
  <!-- Prompt `>` -->
  <path d="M 38 42 L 58 64 L 38 86" fill="none" stroke="#f8fafc" stroke-width="8.5" stroke-linecap="round" stroke-linejoin="round"/>
  <!-- Cursor `_` -->
  <line x1="68" y1="86" x2="92" y2="86" stroke="#f8fafc" stroke-width="8.5" stroke-linecap="round"/>
</svg>""",

    "com.system76.CosmicFiles.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <linearGradient id="folderBack" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="100%" stop-color="#0369a1"/>
    </linearGradient>
    <linearGradient id="folderFront" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#38bdf8"/>
      <stop offset="100%" stop-color="#0ea5e9"/>
    </linearGradient>
    <filter id="folderShadow" x="-10%" y="-10%" width="120%" height="130%">
      <feDropShadow dx="0" dy="4" stdDeviation="4" flood-color="#000000" flood-opacity="0.25"/>
    </filter>
  </defs>
  <!-- Back tab and cover -->
  <path d="M 16 32 C 16 26.5 20.5 22 26 22 L 52 22 C 56 22 59 24.5 62 28 L 68 36 L 102 36 C 107.5 36 112 40.5 112 46 L 112 86 C 112 91.5 107.5 96 102 96 L 26 96 C 20.5 96 16 91.5 16 86 Z" fill="url(#folderBack)"/>
  <!-- Front pocket -->
  <rect x="14" y="42" width="100" height="64" rx="14" ry="14" fill="url(#folderFront)" filter="url(#folderShadow)"/>
  <rect x="14" y="42" width="100" height="64" rx="14" ry="14" fill="none" stroke="#e0f2fe" stroke-width="1.5" stroke-opacity="0.35"/>
</svg>""",

    "brave-browser.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <linearGradient id="flameGrad" x1="10%" y1="90%" x2="90%" y2="10%">
      <stop offset="0%" stop-color="#c026d3"/>
      <stop offset="30%" stop-color="#e11d48"/>
      <stop offset="65%" stop-color="#f97316"/>
      <stop offset="100%" stop-color="#facc15"/>
    </linearGradient>
    <linearGradient id="flameInner" x1="0%" y1="100%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#db2777"/>
      <stop offset="100%" stop-color="#fb923c"/>
    </linearGradient>
    <filter id="swirlGlow" x="-15%" y="-15%" width="130%" height="130%">
      <feDropShadow dx="0" dy="3" stdDeviation="4" flood-color="#f97316" flood-opacity="0.3"/>
    </filter>
  </defs>
  <!-- Sleek circular flame emblem -->
  <circle cx="64" cy="64" r="54" fill="url(#flameGrad)" filter="url(#swirlGlow)"/>
  <!-- Inner swirl cutout curve -->
  <path d="M 64 18 C 78 28 88 44 88 64 C 88 77 77 88 64 88 C 51 88 40 77 40 64 C 40 54 46 45 54 40 C 44 46 36 58 36 70 C 36 86 48 98 64 98 C 84 98 100 82 100 62 C 100 40 84 22 64 18 Z" fill="#1e1b4b" fill-opacity="0.92"/>
  <!-- Inner core flame tongue -->
  <path d="M 64 36 C 68 46 76 54 76 64 C 76 71 71 76 64 76 C 58 76 54 72 54 66 C 54 58 60 50 64 36 Z" fill="url(#flameInner)"/>
</svg>""",

    "com.system76.CosmicEdit.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <linearGradient id="ribbonLeft" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="100%" stop-color="#0369a1"/>
    </linearGradient>
    <linearGradient id="ribbonTop" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#38bdf8"/>
      <stop offset="100%" stop-color="#0284c7"/>
    </linearGradient>
    <linearGradient id="ribbonRight" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#0ea5e9"/>
      <stop offset="100%" stop-color="#0284c7"/>
    </linearGradient>
  </defs>
  <!-- VS Code Modern Origami Ribbon Emblem -->
  <!-- Left wing -->
  <path d="M 22 42 C 18 39 18 33 22 30 L 34 20 C 37 17 42 18 45 22 L 78 54 L 45 86 C 42 90 37 91 34 88 L 22 78 C 18 75 18 69 22 66 L 36 54 Z" fill="url(#ribbonLeft)"/>
  <!-- Upper fold -->
  <path d="M 45 22 L 96 14 C 102 13 108 17 108 23 L 108 105 C 108 111 102 115 96 114 L 45 86 L 78 54 Z" fill="url(#ribbonTop)"/>
  <!-- Right edge facet -->
  <path d="M 88 32 L 108 23 L 108 105 L 88 96 Z" fill="url(#ribbonRight)" fill-opacity="0.75"/>
</svg>""",

    "org.gnome.Showtime.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <linearGradient id="musicBg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#f43f5e"/>
      <stop offset="50%" stop-color="#ec4899"/>
      <stop offset="100%" stop-color="#d946ef"/>
    </linearGradient>
    <filter id="musicShadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="4" stdDeviation="5" flood-color="#be185d" flood-opacity="0.35"/>
    </filter>
  </defs>
  <!-- Squircle Base -->
  <rect x="10" y="10" width="108" height="108" rx="28" ry="28" fill="url(#musicBg)" filter="url(#musicShadow)"/>
  <!-- Beamed Double Musical Eighth Note `♫` -->
  <!-- Left Note Head -->
  <ellipse cx="44" cy="84" rx="14" ry="10" transform="rotate(-20 44 84)" fill="#ffffff"/>
  <!-- Right Note Head -->
  <ellipse cx="84" cy="74" rx="14" ry="10" transform="rotate(-20 84 74)" fill="#ffffff"/>
  <!-- Left Stem -->
  <rect x="52" y="38" width="6.5" height="46" rx="3" fill="#ffffff"/>
  <!-- Right Stem -->
  <rect x="92" y="28" width="6.5" height="46" rx="3" fill="#ffffff"/>
  <!-- Top Connecting Beam -->
  <polygon points="52,38 98.5,28 98.5,40 52,50" fill="#ffffff"/>
</svg>""",

    "com.system76.CosmicViewer.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <linearGradient id="photoBg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#a855f7"/>
      <stop offset="100%" stop-color="#7c3aed"/>
    </linearGradient>
    <filter id="photoShadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="4" stdDeviation="5" flood-color="#6d28d9" flood-opacity="0.35"/>
    </filter>
  </defs>
  <!-- Squircle Base -->
  <rect x="10" y="10" width="108" height="108" rx="28" ry="28" fill="url(#photoBg)" filter="url(#photoShadow)"/>
  <!-- Sun / Moon circle -->
  <circle cx="86" cy="44" r="9" fill="#fef08a"/>
  <!-- Back Mountain Peak -->
  <polygon points="34,88 64,52 88,88" fill="#e9d5ff" fill-opacity="0.6"/>
  <!-- Front Mountain Peak -->
  <polygon points="54,88 78,60 102,88" fill="#ffffff"/>
</svg>""",

    "com.system76.CosmicSettings.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <linearGradient id="gearBg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#475569"/>
      <stop offset="100%" stop-color="#1e293b"/>
    </linearGradient>
    <linearGradient id="gearBorder" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#64748b" stop-opacity="0.6"/>
      <stop offset="100%" stop-color="#1e293b" stop-opacity="0.3"/>
    </linearGradient>
    <filter id="gearShadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="4" stdDeviation="4" flood-color="#000000" flood-opacity="0.3"/>
    </filter>
  </defs>
  <!-- Squircle Base -->
  <rect x="10" y="10" width="108" height="108" rx="28" ry="28" fill="url(#gearBg)" stroke="url(#gearBorder)" stroke-width="2" filter="url(#gearShadow)"/>
  <!-- Gear cog in white -->
  <g fill="#f8fafc">
    <!-- Center circle with hole -->
    <path fill-rule="evenodd" d="M 64 38 C 49.6 38 38 49.6 38 64 C 38 78.4 49.6 90 64 90 C 78.4 90 90 78.4 90 64 C 90 49.6 78.4 38 64 38 Z M 64 54 C 69.5 54 74 58.5 74 64 C 74 69.5 69.5 74 64 74 C 58.5 74 54 69.5 54 64 C 54 58.5 58.5 54 64 54 Z"/>
    <!-- 8 Gear Teeth -->
    <rect x="58" y="26" width="12" height="16" rx="3"/>
    <rect x="58" y="86" width="12" height="16" rx="3"/>
    <rect x="26" y="58" width="16" height="12" rx="3"/>
    <rect x="86" y="58" width="16" height="12" rx="3"/>
    <rect x="58" y="26" width="12" height="16" rx="3" transform="rotate(45 64 64)"/>
    <rect x="58" y="86" width="12" height="16" rx="3" transform="rotate(45 64 64)"/>
    <rect x="26" y="58" width="16" height="12" rx="3" transform="rotate(45 64 64)"/>
    <rect x="86" y="58" width="16" height="12" rx="3" transform="rotate(45 64 64)"/>
  </g>
</svg>""",

    "com.system76.CosmicPanelAppButton.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <!-- Minimal 9-dot App Drawer Grid (3x3 clean circular dots) -->
  <g fill="#f8fafc">
    <!-- Row 1 -->
    <circle cx="36" cy="36" r="8"/>
    <circle cx="64" cy="36" r="8"/>
    <circle cx="92" cy="36" r="8"/>
    <!-- Row 2 -->
    <circle cx="36" cy="64" r="8"/>
    <circle cx="64" cy="64" r="8"/>
    <circle cx="92" cy="64" r="8"/>
    <!-- Row 3 -->
    <circle cx="36" cy="92" r="8"/>
    <circle cx="64" cy="92" r="8"/>
    <circle cx="92" cy="92" r="8"/>
  </g>
</svg>""",
}

def main():
    out_dir = "/mnt/c/Users/YashN/Desktop/MyLinux/config/icons/minimal"
    os.makedirs(out_dir, exist_ok=True)
    for filename, content in ICONS.items():
        path = os.path.join(out_dir, filename)
        with open(path, "w") as f:
            f.write(content.strip() + "\n")
        print(f"Generated {path}")

    # Also symlink or copy aliases
    aliases = {
        "view-app-grid-symbolic.svg": "com.system76.CosmicPanelAppButton.svg",
        "view-grid-symbolic.svg": "com.system76.CosmicPanelAppButton.svg",
        "view-app-grid.svg": "com.system76.CosmicPanelAppButton.svg",
        "org.gnome.Terminal.svg": "com.system76.CosmicTerm.svg",
        "utilities-terminal.svg": "com.system76.CosmicTerm.svg",
        "system-file-manager.svg": "com.system76.CosmicFiles.svg",
        "org.gnome.Nautilus.svg": "com.system76.CosmicFiles.svg",
        "text-editor.svg": "com.system76.CosmicEdit.svg",
        "preferences-system.svg": "com.system76.CosmicSettings.svg",
    }
    for alias, target in aliases.items():
        alias_path = os.path.join(out_dir, alias)
        with open(os.path.join(out_dir, target), "r") as tf:
            with open(alias_path, "w") as af:
                af.write(tf.read())
        print(f"Generated alias {alias_path} -> {target}")

if __name__ == "__main__":
    main()
