SHELL := /usr/bin/env bash

IMAGE ?=
VERSION ?=
TAGS ?=
BASE ?= alpine:latest
BUILD_ARGS ?=
NO_CACHE ?=
PULL ?=
SEVERITY ?= HIGH,CRITICAL
IGNORE_UNFIXED ?= 1
SCANNER_IMAGE ?= aquasec/trivy:latest
SCAN_EXIT_CODE ?= 0

.PHONY: help list new tags build push release scan lint check-image check-version

help:
	@printf '%s\n' \
		'Targets:' \
		'  make list                                  List image folders' \
		'  make new IMAGE=name [BASE=alpine:latest]   Create a new image folder' \
		'  make tags IMAGE=name [VERSION=x] [TAGS=...] Print Docker tags' \
		'  make build IMAGE=name VERSION=x [TAGS=...] [BUILD_ARGS=...] [NO_CACHE=1] [PULL=1] Build locally' \
		'  make push IMAGE=name [VERSION=x] [TAGS=...] Push existing local tags and record version' \
		'  make release IMAGE=name [VERSION=x] [TAGS=...] [BUILD_ARGS=...] [NO_CACHE=1] [PULL=1] Build, push, and record next version' \
		'  make scan IMAGE=name VERSION=x [SEVERITY=HIGH,CRITICAL] [SCAN_EXIT_CODE=0] Scan image with Trivy' \
		'  make lint                                  Run hadolint when installed'

list:
	@find images -mindepth 1 -maxdepth 1 -type d ! -name '_template' -print 2>/dev/null | sed 's#^images/##' | sort

new: check-image
	@scripts/new-image.sh "$(IMAGE)" "$(BASE)"

tags: check-image
	@TAGS="$(TAGS)" scripts/tags.sh "$(IMAGE)" "$(VERSION)"

build: check-image check-version
	@TAGS="$(TAGS)" EXTRA_BUILD_ARGS="$(BUILD_ARGS)" NO_CACHE="$(NO_CACHE)" PULL="$(PULL)" scripts/build.sh "$(IMAGE)" "$(VERSION)"

push: check-image
	@TAGS="$(TAGS)" scripts/push.sh "$(IMAGE)" "$(VERSION)"

release: check-image
	@TAGS="$(TAGS)" EXTRA_BUILD_ARGS="$(BUILD_ARGS)" NO_CACHE="$(NO_CACHE)" PULL="$(PULL)" scripts/release.sh "$(IMAGE)" "$(VERSION)"

scan: check-image check-version
	@SEVERITY="$(SEVERITY)" IGNORE_UNFIXED="$(IGNORE_UNFIXED)" SCANNER_IMAGE="$(SCANNER_IMAGE)" SCAN_EXIT_CODE="$(SCAN_EXIT_CODE)" scripts/scan.sh "$(IMAGE)" "$(VERSION)"

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
