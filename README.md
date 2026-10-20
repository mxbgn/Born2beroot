# Born2beroot

Born2beroot is a system administration project focused on deploying and securing a Debian-based Linux server inside a virtual machine.

This repository automates the process at two levels:
- **Installation automation:** Debian Installer preseed configuration for automating initial installation settings, such as locale, keyboard layout, timezone, and eventually disk partitioning.
- **System configuration:** Bash scripts and a Makefile for automating user management, password policies, SSH hardening, firewall configuration, system monitoring, and other post-installation tasks.

The project is inspired by the 42 Born2beroot curriculum, with an emphasis on reproducibility, security, and system administration fundamentals.

## Setup

### Prerequisites

- A hypervisor capable of running Debian virtual machines (e.g. QEMU/KVM with virt-manager) with minimum 30GB disk space.
- A Debian installation ISO compatible with the preseed configuration.
- Git and an active network connection.
- Bash and GNU Make.
- Administrative privileges on the installed Debian system.

### Installation

#### 1. Create the virtual machine

Create the VM using BIOS firmware in QEMU/KVM with virt-manager, attach the Debian installation ISO, and configure a virtual disk and network connection.

#### 2. Boot the installer with the preseed configuration

At the Debian installer boot menu, select **Install** and edit its boot parameters.
Depending on the boot menu, press `Tab` (ISOLINUX) or `e` (GRUB) to edit the entry. Append the following parameters to the existing kernel command line:
```text
auto=true url=https://raw.githubusercontent.com/mxbgn/Born2beroot/main/preseed.cfg
```

Boot the edited entry. The installer will attempt to retrieve the configuration and use its answers during installation.
Follow any remaining interactive prompts. Settings not supplied by the preseed may use installer defaults, be skipped, or require manual input.

#### 4. Run the post-installation setup

Long into the debian session as root and clone the repository:
```bash
git clone https://github.com/mxbgn/Born2beroot.git
cd Born2beroot
```

Run the environment setup:
```bash
sudo make
```

To include user setup, specify a username:
```bash
sudo make USER=<username>
```

To run only user creation and its dependencies:
```bash
sudo make user USER=<username>
```

### Testing

Run the setup tests:
```bash
make test
```

To test the setup with user creation:
```bash
make test USER=<username>
```

The setup and testing scripts are designed to be idempotent and require appropriate administrative privileges for system-level operations.

## Repository structure

- `preseed.cfg` — Debian Installer preseed configuration.
- `scripts/` — Bash scripts for system configuration and user management.
- `Makefile` — Entry points for setup and testing.

## Disclaimer

This repository is intended for educational purposes as part of the 42 Born2beroot project.

Configuration choices should be reviewed and adapted to the target system before use. In particular, partitioning, disk encryption, account credentials, SSH settings, and firewall rules should be tested in a disposable virtual machine before being applied to a system containing important data.
