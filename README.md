# Born2beroot

Born2beroot is a sytem administration project focused on deploying a Debian-based linux server on a virtual machine.
This repository contains Bash scripts to automate system configuration, user management, password policies, SSH hardening, firewall setup, and system monitoring.

## Setup

### Prerequisites

- A Debian-based Linux virtual machine
- bash
- make
- sudo privileges
- An active network connection for package installation

### Instructions
Clone the repository:
```bash
git clone https://github.com/mxbgn/Born2beroot.git
cd born2beroot
```

Run the complete setup with the username to configure:
```bash
make USERNAME=<username>
```
Replace <username> with the appropriate existing or intended user account, according to the behavior of user-groups.sh.

The setup scripts require administrative privileges and use sudo where needed.

## Disclaimer

This repository is intended for educational purposes as part of the 42 Born2beroot project.
Configuration choices should be reviewed and adapted to the target system before use.
