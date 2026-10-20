# Architecture

## Overview

Born2beroot is a system administration project focused on deploying and configuring a Debian-based virtual machine.

The setup is divided into two stages:

1. **Automated installation** — Debian Installer uses a preseed configuration to automate installation settings.
2. **Post-installation configuration** — a Makefile and Bash scripts configure the installed system, including user management, security policies, SSH, firewall rules, and system monitoring.

This separation keeps operating system installation independent from system configuration.

## System Architecture

```text
Host machine
└── QEMU/KVM virtual machine
    └── Debian GNU/Linux
        ├── Debian Installer
        │   └── preseed.cfg
        │       ├── Locale and keyboard
        │       ├── Timezone
        │       ├── Minimal package selection
        │       ├── Disk partitioning and encryption
        │       ├── Package mirror configuration
        │       └── Bootloader and reboot
        │
        └── Post-installation configuration
            ├── Makefile
            └── Bash scripts
                ├── User management
                ├── Password policies
                ├── SSH hardening
                ├── Firewall configuration
                └── System monitoring
```

## Virtualization

The system runs inside a virtual machine providing its own virtual disk, network interface, and firmware configuration.
The installation is designed for BIOS firmware. The virtual disk is dedicated to the VM and may be erased during automated partitioning.
A minimum of 30GB disk space for the VM is advised.

## Automated Debian Installation

The file `preseed.cfg` contains answers for supported Debian Installer questions.
It aims to reduce manual interaction during installation while keeping sensitive credentials out of the repository.

### Locale and regional settings

The preseed configures:
- Locale: `en_GB.UTF-8`
- Keyboard layout: `gb`
- Timezone: `Europe/Berlin`
- UTC-based system clock

### User account setup

Creation of a regular user during installation is disabled so that account creation can be handled by the post-installation scripts.
The root account remains enabled. Passwords and encryption passphrases should be entered interactively.

### Package selection

The installation avoids selecting additional task groups, such as a desktop environment.
The package mirror is configured to use `deb.debian.org`, without an HTTP proxy.
The Debian package popularity contest is disabled.

### Disk partitioning and encryption

The intended partition layout uses an unencrypted `/boot` partition and encrypted LVM for the remaining filesystems.
| Mount point | Intended size | Purpose |
|---|---:|---|
| `/boot` | 500 MiB | Kernel and boot files |
| `/` | 10 GiB | Root filesystem |
| `/home` | At least 5 GiB | User home directories; intended to use remaining space |
| `/var` | 3 GiB | Variable application and system data |
| `/var/log` | 4 GiB | System and application logs |
| `/srv` | 3 GiB | Data served by system services |
| Swap | 2.3 GiB | Swap space |

### Bootloader and completion

The installer is configured to install GRUB to the default boot device and proceed through the final reboot step.
The installation ISO may need to be detached, or the boot order changed, to ensure the VM starts from its installed system afterward.

## Post-installation Configuration

After Debian has been installed, the repository's Makefile provides an entry point for the Bash configuration scripts.
The post-installation stage is responsible for applying the project's system configuration and security settings.

## Post-installation Configuration

After Debian has been installed, the Makefile orchestrates the post-installation configuration through Bash scripts. This stage applies the user management, security policies, service configuration, and monitoring required by the Born2beroot project.

### User Management and Privileges

The user-management scripts create and configure the regular user specified through the `USER` Makefile variable.

The configuration is designed to meet the following requirements:
- Create a regular user separate from `root`.
- Add the user to the `sudo` group to grant administrative privileges through controlled privilege escalation.
- Configure account and group membership consistently, including when the setup is rerun.

### Password Policies

The password-policy scripts configure password quality requirements and password aging rules using Linux PAM and account-management tools.
The intended policy includes:
| Policy | Requirement |
|---|---|
| Minimum password length | 10 characters |
| Character requirements | At least one uppercase letter, one lowercase letter, and one digit |
| Repeated characters | No more than 3 consecutive identical characters |
| Username restriction | Password must not contain the username |
| Password history difference | At least 7 characters must differ from the previous password, where applicable |
| Maximum password age | 30 days |
| Minimum password age | 2 days |
| Expiration warning | 7 days |

Password quality is enforced through PAM, typically using `pam_pwquality`, while password aging is configured through account-aging settings.

### Sudo Configuration

The sudo configuration scripts harden administrative command execution and provide an audit trail.
The intended configuration includes:
- Limit password authentication attempts to 3.
- Display a custom message when sudo authentication fails.
- Log sudo command activity, including input and output where required.
- Store sudo logs under `/var/log/sudo/`.
- Require a terminal for sudo execution, where supported by the target system.
- Define a restricted `secure_path` for commands executed with elevated privileges.

These settings are applied through sudo's configuration system using a dedicated file under `/etc/sudoers.d/`.
The purpose is to reduce the risk of unsafe administrative execution and make privileged activity auditable.

### SSH Hardening

The SSH scripts configure the OpenSSH server for secure remote administration.
The intended configuration follows these requirements:
- Disable direct root login over SSH.
- Ensure the SSH service is enabled and available after boot.
- Validate the SSH configuration before restarting or reloading the service.

Remote administration is performed using a regular user account with appropriate privileges. Disabling root login requires administrators to authenticate as a permitted user and escalate privileges when necessary.

### Firewall Configuration

The firewall scripts configure UFW (Uncomplicated Firewall) to restrict incoming network traffic.
The intended Born2beroot configuration includes:
- Enable UFW and ensure it remains active after reboot.
- Allow incoming SSH connections on TCP port `22`.
- Deny other unsolicited incoming connections unless explicitly required.
- Preserve the ability to administer the machine remotely without exposing unnecessary services.

### System Monitoring

The monitoring script, commonly named `monitoring.sh`, gathers information about the system and displays it periodically using `logger -t monitoring`. It can be read using `sudo journalctl -t monitoring`.
The intended report covers:
- Operating system architecture and kernel version.
- Number of physical processors and virtual CPUs.
- Available RAM and memory utilization.
- Available disk space and storage utilization.
- CPU utilization.
- Date and time of the last reboot.
- Whether LVM is active.
- Number of active TCP connections.
- Number of currently logged-in users.
- IPv4 address and MAC address.
- Number of commands executed using sudo.

The script is intended to run automatically every 10 minutes through cron, including after the system has booted.
Monitoring provides a lightweight overview of system health, resource consumption, and administrative activity without requiring a graphical interface.

### Mandatory Security Service

On Debian, AppArmor provides mandatory access control by restricting the capabilities of applications according to their security profiles.
This adds a layer of protection alongside user permissions, SSH hardening, password policies, and firewall rules.

## Makefile Interface

The Makefile provides commands for running the configuration and testing workflows.
Examples:

```bash
# Run the default configuration target
sudo make

# Run configuration with a specified new users username
sudo make USER=<username>

# Run only user creation and its dependencies
sudo make user USER=<username>

# Run tests
make test

# Run tests for a specified user
make test USER=<username>
```

## Design Principles

The project follows several principles:

- **Separation of concerns:** installation and post-installation configuration are managed independently.
- **Automation:** repetitive system administration tasks are handled by preseed settings and scripts.
- **Security:** sensitive credentials are not committed to version control.
- **Reproducibility:** the same configuration can be applied to a fresh VM.
- **Idempotency:** scripts should be safe to rerun without unnecessarily duplicating changes.
- **Testability:** configuration behavior can be checked using the project's test targets.

## Limitations and Validation

The installer configuration must be tested against the chosen Debian ISO and virtual machine firmware.
In particular, validate:

- Encrypted LVM creation and the interactive encryption passphrase prompt.
- The final partition sizes and mount points.
- Root account access and subsequent regular-user creation.
- GRUB installation and successful reboot.
- Post-installation script behavior and idempotency.

The repository is intended for educational purposes as part of the 42 Born2beroot project. Implementation features variations from the original subject.
