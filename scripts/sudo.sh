#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root." >&2
    exit 1
fi

if ! dpkg -l sudo | grep -q '^ii'; then
    bash scripts/dependencies.sh
fi

mkdir -p /var/log/sudo
cat >/etc/sudoers.d/sudo_config <<'EOF'
Defaults  passwd_tries=3
Defaults  badpass_message="Error: Incorrect password"
Defaults  logfile="/var/log/sudo/sudo_config"
Defaults  log_input, log_output
Defaults  iolog_dir="/var/log/sudo"
Defaults  requiretty
Defaults  secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
EOF
