#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root." >&2
    exit 1
fi

TARGET_USER="${1:-}"
if [[ -n "$TARGET_USER" ]]; then
    if ! id "$TARGET_USER" >/dev/null 2>&1; then
        useradd -m -s /bin/bash "$TARGET_USER"
    fi
    passwd "$TARGET_USER"
fi

if ! getent group sudo >/dev/null 2>&1; then
    groupadd sudo
fi
if [[ -n "$TARGET_USER" ]]; then
    usermod -aG sudo "$TARGET_USER"
fi
