#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root." >&2
    exit 1
fi

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: $0 <username>" >&2
    exit 1
fi

TARGET_USER="$1"

if ! id "$TARGET_USER" >/dev/null 2>&1; then
    useradd -m "$TARGET_USER"
fi

for group in sudo user42; do
    if ! getent group "$group" >/dev/null 2>&1; then
        groupadd "$group"
    fi
    usermod -aG "$group" "$TARGET_USER"
done

echo "User '$TARGET_USER' is configured successfully."

