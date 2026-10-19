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
cd Born2beroot
```

Run the environment setup with `make` or add user setup with `make USER=<username>`.
Run `make user USER=<username>` to run only the user creation and it's dependencies.

The debian session configuration setup can be tested with `make test` or `make test USER=<username>` to add user setup testing.

The setup and testing scripts are idempotent and require administrative privileges.

## Disclaimer

This repository is intended for educational purposes as part of the 42 Born2beroot project.
Configuration choices should be reviewed and adapted to the target system before use.
