#!/bin/bash
set -uo pipefail

PASS=0
FAIL=0
WARN=0

pass() { echo -e "[PASS] $1"; ((PASS+=1)); }
fail() { echo -e "[FAIL] $1"; ((FAIL+=1)); }
warn() { echo -e "[WARN] $1"; ((WARN+=1)); }

check_value() {
    local description="$1"
    local actual="$2"
    local expected="$3"

    if [[ "$actual" == "$expected" ]]; then
        pass "$description"
    else
        fail "$description (expected: $expected, got: ${actual:-unset})"
    fi
}

# Locale
check_value "Locale" \
    "$(locale -a 2>/dev/null | grep -ix 'en_GB.utf8' | head -n1)" \
    "en_GB.utf8"

# Keyboard layout
check_value "Keyboard layout" \
    "$(grep -E '^XKBLAYOUT=' /etc/default/keyboard 2>/dev/null | cut -d= -f2 | tr -d '"')" \
    "gb"

# Timezone
check_value "Timezone" \
    "readlink -f /etc/localtime | sed 's|.*/zoneinfo/||" \
    "Europe/Berlin"

# BIOS firmware
if [[ ! -d /sys/firmware/efi ]]; then
    pass "Booted in BIOS mode"
else
    fail "System booted in UEFI mode, not BIOS"
fi

# /boot filesystem
if findmnt -rn -M /boot >/dev/null 2>&1; then
    BOOT_TYPE=$(findmnt -rn -M /boot -o FSTYPE)
    BOOT_SIZE=$(df -BM --output=size /boot | tail -n1 | tr -dc '0-9')

    if [[ "$BOOT_TYPE" == "ext4" ]]; then
        pass "/boot is a separate ext4 filesystem"
    else
        fail "/boot filesystem is $BOOT_TYPE, expected ext4"
    fi

    if [[ "$BOOT_SIZE" -ge 400 && "$BOOT_SIZE" -le 600 ]]; then
        pass "/boot size is approximately 500 MiB"
    else
        warn "/boot size is ${BOOT_SIZE:-unknown} MiB; expected approximately 500 MiB"
    fi
else
    fail "/boot is not a separate mounted filesystem"
fi

# Encrypted root
ROOT_SOURCE=$(findmnt -rn -o SOURCE /)
ROOT_TYPE=$(lsblk -no TYPE "$ROOT_SOURCE" 2>/dev/null | head -n1)

if [[ "$ROOT_TYPE" == "crypt" ]] || \
   lsblk -s -no TYPE "$ROOT_SOURCE" 2>/dev/null | grep -qx crypt; then
    pass "Root filesystem appears to be backed by encryption"
else
    fail "Could not verify encrypted root filesystem"
fi

# LVM
if command -v vgs >/dev/null 2>&1 && \
   vgs --noheadings 2>/dev/null | grep -q .; then
    pass "LVM volume group detected"
else
    fail "No LVM volume group detected"
fi

# Expected mount points
for mount in /home /var /var/log /srv; do
    if findmnt -rn -M "$mount" >/dev/null 2>&1; then
        pass "$mount is a separate mounted filesystem"
    else
        fail "$mount is not a separate mounted filesystem"
    fi
done

# Swap
if swapon --show --noheadings 2>/dev/null | grep -q .; then
    pass "Swap is active"
else
    fail "No active swap detected"
fi

# Package mirror
if grep -RhsE '^[[:space:]]*(deb[[:space:]]|URIs:)' \
    /etc/apt/sources.list /etc/apt/sources.list.d \
    2>/dev/null | grep -q 'deb.debian.org'; then
    pass "APT sources reference deb.debian.org"
else
    fail "Could not find deb.debian.org in APT sources"
fi

# Popularity contest
if ! dpkg-query -W -f='${Status}' popularity-contest 2>/dev/null |
    grep -q 'install ok installed'; then
    pass "Popularity contest package is not installed"
elif grep -Eq '^[[:space:]]*PARTICIPATE[[:space:]]*=[[:space:]]*no' \
    /etc/popularity-contest.conf 2>/dev/null; then
    pass "Popularity contest participation is disabled"
else
    warn "Popularity contest is installed; participation setting needs checking"
fi

# GRUB
if command -v grub-install >/dev/null 2>&1 && \
   [[ -d /boot/grub ]]; then
    pass "GRUB appears to be installed"
else
    fail "GRUB installation could not be verified"
fi

if (( FAIL > 0 )); then
    echo "Some checks failed. Review the output above."
    exit 1
else
    echo "All mandatory checks passed; review warnings if any."
    exit 0
fi

