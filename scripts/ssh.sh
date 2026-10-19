#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root." >&2
    exit 1
fi

if ! dpkg -l openssh-server | grep -q '^ii'; then
    bash scripts/dependencies.sh
fi

cat >/etc/ssh/sshd_config.d/99-custom.conf <<'EOF'
Port 4242
PermitRootLogin no
EOF
echo "Port 4242" > /etc/ssh/ssh_config.d/99-custom.conf

if /usr/sbin/sshd -t; then
    systemctl reload ssh
else
    echo "Error: invalid SSH configuration." >&2
    exit 1
fi
