#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root." >&2
    exit 1
fi

if ! dpkg -s ufw >/dev/null 2>&1 || ! dpkg -s apparmor >/dev/null 2>&1; then
    bash scripts/dependencies.sh
fi

systemctl enable --now apparmor

ufw allow 22/tcp >/dev/null
ufw --force enable >/dev/null

