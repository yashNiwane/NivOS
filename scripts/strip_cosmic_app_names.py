#!/usr/bin/env python3
"""
Strip the word 'COSMIC' / 'Cosmic' from application names in .desktop files
so they appear cleanly as 'Terminal', 'Files', 'Text Editor', 'Settings', etc.
"""

import os
import re
import sys

TARGET_DIR = sys.argv[1] if len(sys.argv) > 1 else "/var/tmp/nivos-build/chroot/usr/share/applications"

REPLACEMENTS = {
    "com.system76.CosmicTerm.desktop": {
        "primary": "Terminal",
    },
    "com.system76.CosmicFiles.desktop": {
        "primary": "Files",
    },
    "com.system76.CosmicEdit.desktop": {
        "primary": "Text Editor",
    },
    "com.system76.CosmicSettings.desktop": {
        "primary": "Settings",
    },
    "com.system76.CosmicMonitor.desktop": {
        "primary": "System Monitor",
    },
    "com.system76.CosmicStore.desktop": {
        "primary": "Store",
    },
    "com.system76.CosmicScreenshot.desktop": {
        "primary": "Screenshot",
    },
    "com.system76.CosmicViewer.desktop": {
        "primary": "Image Viewer",
    },
}

def clean_desktop_file(filepath, primary_name):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        if line.startswith("Name="):
            new_lines.append(f"Name={primary_name}\n")
        elif line.startswith("GenericName="):
            new_lines.append(f"GenericName={primary_name}\n")
        elif line.startswith("Name["):
            # Strip Cosmic / COSMIC from localized names
            cleaned = re.sub(r'\b(COSMIC|Cosmic)\s*', '', line)
            cleaned = re.sub(r'\s*\b(del|de|na|на)\s*(COSMIC|Cosmic)\b', '', cleaned, flags=re.IGNORECASE)
            new_lines.append(cleaned)
        elif line.startswith("GenericName["):
            cleaned = re.sub(r'\b(COSMIC|Cosmic)\s*', '', line)
            new_lines.append(cleaned)
        else:
            new_lines.append(line)

    with open(filepath, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    print(f"Updated {os.path.basename(filepath)} -> Name={primary_name}")

def main():
    if not os.path.isdir(TARGET_DIR):
        print(f"Directory not found: {TARGET_DIR}", file=sys.stderr)
        sys.exit(1)

    for filename, config in REPLACEMENTS.items():
        filepath = os.path.join(TARGET_DIR, filename)
        if os.path.exists(filepath):
            clean_desktop_file(filepath, config["primary"])
        else:
            print(f"Warning: {filepath} does not exist, skipping.")

if __name__ == "__main__":
    main()
