SHELL := /bin/bash

.PHONY: all dependencies sudo user-groups password ssh firewall monitoring

USERNAME ?=

all: monitoring

dependencies:
	sudo scripts/dependencies.sh

sudo: dependencies
	sudo scripts/sudo.sh

user-groups: sudo
	@test -n "$(USERNAME)" || (echo "Usage: make user-groups USERNAME=<username>" >&2; exit 1)
	sudo scripts/user-groups.sh "$(USERNAME)"

password: user-groups
	sudo scripts/password.sh

ssh: password
	sudo scripts/ssh.sh

firewall: ssh
	sudo scripts/firewall.sh

monitoring: firewall
	sudo scripts/monitoring.sh
