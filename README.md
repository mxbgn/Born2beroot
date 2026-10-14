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

Run the complete setup to configure with `make` and provide a new username and password interactively. Run `make user` to run only the user creation and it's dependencies.
a new user's name and password are interactively requested: provide an empty username to skip user creation.
The setup scripts are idempotent and require administrative privileges.

## Disclaimer

This repository is intended for educational purposes as part of the 42 Born2beroot project.
Configuration choices should be reviewed and adapted to the target system before use.
