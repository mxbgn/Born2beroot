#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root."
    exit 1
fi

failed=0
TARGET_USER="${1:-}"

test_user() {
    for group in sudo user42; do
        if getent group "$group" >/dev/null 2>&1; then
            if id -nG "$TARGET_USER" | grep -qw "$group"; then
                echo "PASS: user is in '$group' group"
            else
                echo "FAIL: user is not in '$group' group"
                failed=1
            fi
        else
            echo "FAIL: Missing group '$group'"
            failed=1
        fi
    done

    max_days=$(chage -l "$TARGET_USER" | awk -F': ' '/Maximum number of days between password change/ {print $2}')
    min_days=$(chage -l "$TARGET_USER" | awk -F': ' '/Minimum number of days between password change/ {print $2}')

    if [[ "$max_days" -eq 90 ]]; then
        echo "PASS: Maximum password age is 90 days"
    else
        echo "FAIL: Maximum password age is $max_days days (expected 90)"
        failed=1
    fi
    
    if [[ "$min_days" -eq 2 ]]; then
        echo "PASS: Minimum password age is 2 days"
    else
        echo "FAIL: Minimum password age is $min_days days (expected 2)"
        failed=1
    fi

    PAM_FILE="/etc/pam.d/common-password"

    if grep -q 'pam_pwquality.so' "$PAM_FILE" &&
       grep -q 'minlen=10' "$PAM_FILE" &&
       grep -q 'ucredit=-1' "$PAM_FILE" &&
       grep -q 'dcredit=-1' "$PAM_FILE" &&
       grep -q 'lcredit=-1' "$PAM_FILE" &&
       grep -q 'maxrepeat=3' "$PAM_FILE" &&
       grep -q 'reject_username' "$PAM_FILE" &&
       grep -q 'difok=7' "$PAM_FILE" &&
       grep -q 'enforce_for_root' "$PAM_FILE"; then
        echo "PASS: Password policy options configured"
    else
        echo "FAIL: Password policy options missing"
        failed=1
    fi
}

test_ssh() {
    if systemctl is-active --quiet ssh; then
        echo "PASS: SSH service is running"
    else
        echo "FAIL: SSH service is not running"
        failed=1
    fi

    if sshd -T 2>/dev/null | grep -qx 'permitrootlogin no'; then
        echo "PASS: Root SSH login is disabled"
    else
        echo "FAIL: Root SSH login is not disabled"
        failed=1
    fi

    if sshd -T 2>/dev/null | grep -q 'port 4242'; then
        echo "PASS: SSH port 4242 is listening"
    else
        echo "FAIL: SSH port 4242 is not listening"
        failed=1
    fi
}

test_firewall() {
    if ufw status | grep -q '^Status: active'; then
        echo "PASS: Firewall is active"
    else
        echo "FAIL: Firewall is not active"
        failed=1
    fi

    if ufw status | grep -qE '4242/tcp[[:space:]]+ALLOW'; then
        echo "PASS: Port 4242/tcp is allowed"
    else
        echo "FAIL: Port 4242/tcp is not allowed"
        failed=1
    fi
}

test_monitoring() {
    if [[ -x /usr/local/bin/monitoring.sh ]]; then
        echo "PASS: Monitoring script is executable"
    else
        echo "FAIL: Monitoring script missing or not executable"
        failed=1
    fi

    if crontab -u root -l 2>/dev/null | grep -Fq '/usr/local/bin/monitoring.sh'; then
        echo "PASS: Monitoring cron job is configured"
    else
        echo "FAIL: Monitoring cron job is missing"
        failed=1
    fi
}

if [[ -n "$TARGET_USER" ]]; then
    if id "$TARGET_USER" >/dev/null 2>&1; then
        test_user
    else
        echo "Error: user '$TARGET_USER' does not exist." >&2
        failed=1
    fi
fi

test_ssh
test_firewall
test_monitoring

exit "$failed"
