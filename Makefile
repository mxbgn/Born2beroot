SHELL := /bin/bash

.PHONY: all user test

USERNAME ?=

all:
	@scripts/sudo.sh
	@scripts/password.sh
	@scripts/user-groups.sh "$(USERNAME)"
	@scripts/ssh.sh
	@scripts/firewall.sh
	@scripts/monitoring.sh

user:
	@scripts/sudo.sh
	@scripts/password.sh
	@scripts/user-groups.sh "$(USERNAME)"

test:
	@scripts/test.sh
