SHELL := /bin/bash

.PHONY: all user test

USER ?=

all:
	@scripts/sudo.sh
	@scripts/password.sh
	@scripts/user-groups.sh "$(USERNAME)"
	@scripts/ssh.sh
	@scripts/security.sh
	@scripts/monitoring.sh

user:
	@scripts/sudo.sh
	@scripts/password.sh
	@scripts/user-groups.sh "$(USERNAME)"

test:
	@test/seed.sh
	@test/config.sh "$(USERNAME)"
