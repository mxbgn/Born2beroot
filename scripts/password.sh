#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root." >&2
    exit 1
fi

if ! dpkg -l libpam-pwquality | grep -q '^ii'; then
    bash dependencies.sh
fi

sed -i 's/^PASS_MAX_DAYS[[:space:]].*/PASS_MAX_DAYS 90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS[[:space:]].*/PASS_MIN_DAYS 2/' /etc/login.defs
sed -i '/pam_pwquality\.so/c\password requisite pam_pwquality.so retry=3 minlen=10 ucredit=-1 dcredit=-1 lcredit=-1 maxrepeat=3 reject_username difok=7 enforce_for_root' /etc/pam.d/common-password
