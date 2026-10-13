#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root." >&2
    exit 1
fi

apt-get update
apt-get intall -y sudo ssh-server ufw libpam-pwquality
