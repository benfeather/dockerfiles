SHELL := /usr/bin/env bash

IMAGE ?=
VERSION ?=
TAGS ?=
BASE ?= alpine:latest

.PHONY: help list new tags build push release lint check-image check-version

help:
	@printf '%s\n' \
		'Targets:' \
		'  make list                                  List image folders' \
		'  make new IMAGE=name [BASE=alpine:latest]   Create a new image folder' \
		'  make tags IMAGE=name [VERSION=x] [TAGS=...] Print Docker tags' \
		'  make build IMAGE=name VERSION=x [TAGS=...] Build locally' \
		'  make push IMAGE=name [VERSION=x] [TAGS=...] Push existing local tags and record version' \
		'  make release IMAGE=name [VERSION=x] [TAGS=...] Build, push, and record next version' \
		'  make lint                                  Run hadolint when installed'

list:
	@find images -mindepth 1 -maxdepth 1 -type d ! -name '_template' -print 2>/dev/null | sed 's#^images/##' | sort

new: check-image
	@scripts/new-image.sh "$(IMAGE)" "$(BASE)"

tags: check-image
	@TAGS="$(TAGS)" scripts/tags.sh "$(IMAGE)" "$(VERSION)"

build: check-image check-version
	@TAGS="$(TAGS)" scripts/build.sh "$(IMAGE)" "$(VERSION)"

push: check-image
	@TAGS="$(TAGS)" scripts/push.sh "$(IMAGE)" "$(VERSION)"

release: check-image
	@TAGS="$(TAGS)" scripts/release.sh "$(IMAGE)" "$(VERSION)"

lint:
	@if command -v hadolint >/dev/null 2>&1; then \
		find images -name Dockerfile -not -path '*/_template/*' -print0 | xargs -0 hadolint; \
	else \
		printf '%s\n' 'hadolint is not installed; skipping Dockerfile lint.'; \
	fi

check-image:
	@test -n "$(IMAGE)" || { printf '%s\n' 'IMAGE is required. Example: make build IMAGE=alpine-tools VERSION=0.1.0' >&2; exit 2; }

check-version:
	@test -n "$(VERSION)" || { printf '%s\n' 'VERSION is required. Example: make build IMAGE=alpine-tools VERSION=0.1.0' >&2; exit 2; }
