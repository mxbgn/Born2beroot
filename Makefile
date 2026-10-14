SHELL := /bin/bash

.PHONY: all sudo user-groups password ssh firewall monitoring

USERNAME ?=

all: monitoring

sudo:
	scripts/sudo.sh

user-groups: sudo
	@test -n "$(USERNAME)" || (echo "Usage: make USERNAME=<username>" >&2; exit 1)
	scripts/user-groups.sh "$(USERNAME)"

password: user-groups
	scripts/password.sh

ssh: password
	scripts/ssh.sh

firewall: ssh
	scripts/firewall.sh

monitoring: firewall
	scripts/monitoring.sh
