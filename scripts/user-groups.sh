#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root." >&2
    exit 1
fi

TARGET_USER="${1:-}"

if [[ -z "$TARGET_USER" ]]; then
    read -rp "Enter the username to create: " TARGET_USER
fi

if [[ -n "$TARGET_USER" ]] && ! id "$TARGET_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$TARGET_USER"
    passwd "$TARGET_USER"
fi

for group in sudo user42; do
    if ! getent group "$group" >/dev/null 2>&1; then
        groupadd "$group"
    fi
    usermod -aG "$group" "$TARGET_USER"
done
