#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root." >&2
    exit 1
fi

if ! dpkg -l ufw | grep -q '^ii'; then
    bash dependencies.sh
fi

ufw allow 4242/tcp
ufw --force enable
