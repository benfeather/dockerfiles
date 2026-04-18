#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required but was not found"
}

load_dotenv() {
  if [ -f "$ROOT_DIR/.env" ]; then
    set -a
    # shellcheck disable=SC1091
    . "$ROOT_DIR/.env"
    set +a
  fi
}

load_image_config() {
  IMAGE="$1"
  [ -n "$IMAGE" ] || fail "image name is required"

  IMAGE_DIR="$ROOT_DIR/images/$IMAGE"
  VERSION_FILE="$IMAGE_DIR/VERSION"
  [ -d "$IMAGE_DIR" ] || fail "image folder not found: images/$IMAGE"

  local config="$IMAGE_DIR/image.env"
  [ -f "$config" ] || fail "image config not found: images/$IMAGE/image.env"

  IMAGE_NAME=
  CONTEXT=
  DOCKERFILE=
  PLATFORMS=
  DEFAULT_TAGS=
  BUILD_ARGS=

  set -a
  # shellcheck disable=SC1090
  . "$config"
  set +a

  IMAGE_NAME="${IMAGE_NAME:-$IMAGE}"
  CONTEXT="${CONTEXT:-images/$IMAGE}"
  DOCKERFILE="${DOCKERFILE:-$CONTEXT/Dockerfile}"
  PLATFORMS="${PLATFORMS:-linux/amd64}"
  DEFAULT_TAGS="${DEFAULT_TAGS:-}"
  BUILD_ARGS="${BUILD_ARGS:-}"
  EXTRA_BUILD_ARGS="${EXTRA_BUILD_ARGS:-}"

  [ -f "$ROOT_DIR/$DOCKERFILE" ] || fail "Dockerfile not found: $DOCKERFILE"
  [ -d "$ROOT_DIR/$CONTEXT" ] || fail "context folder not found: $CONTEXT"
}

require_namespace() {
  DOCKERHUB_NAMESPACE="${DOCKERHUB_NAMESPACE:-}"
  [ -n "$DOCKERHUB_NAMESPACE" ] || fail "set DOCKERHUB_NAMESPACE in .env or the environment"
}

image_repository() {
  require_namespace

  if [ -n "${REGISTRY:-}" ]; then
    printf '%s/%s/%s\n' "${REGISTRY%/}" "$DOCKERHUB_NAMESPACE" "$IMAGE_NAME"
  else
    printf '%s/%s\n' "$DOCKERHUB_NAMESPACE" "$IMAGE_NAME"
  fi
}

all_tags() {
  local version="$1"
  local repo
  local tag
  local seen=" "

  [ -n "$version" ] || fail "version is required"
  repo="$(image_repository)"

  for tag in "$version" $DEFAULT_TAGS ${TAGS:-}; do
    [ -n "$tag" ] || continue
    case "$seen" in
      *" $tag "*) continue ;;
    esac
    seen="$seen$tag "
    printf '%s:%s\n' "$repo" "$tag"
  done
}

append_tag_flags() {
  local version="$1"
  local tag

  TAG_FLAGS=()
  while IFS= read -r tag; do
    TAG_FLAGS+=("-t" "$tag")
  done < <(all_tags "$version")
}

append_build_arg_flags() {
  local arg

  BUILD_ARG_FLAGS=("--build-arg" "IMAGE_VERSION=$VERSION")
  for arg in $BUILD_ARGS $EXTRA_BUILD_ARGS; do
    [ -n "$arg" ] || continue
    BUILD_ARG_FLAGS+=("--build-arg" "$arg")
  done
}

append_cache_flags() {
  CACHE_FLAGS=()

  case "${NO_CACHE:-}" in
    1|true|TRUE|yes|YES) CACHE_FLAGS+=("--no-cache") ;;
  esac

  case "${PULL:-}" in
    1|true|TRUE|yes|YES) CACHE_FLAGS+=("--pull") ;;
  esac
}

current_image_version() {
  if [ -f "$VERSION_FILE" ]; then
    tr -d '[:space:]' < "$VERSION_FILE"
  else
    printf '%s\n' "0.0.0"
  fi
}

assert_incrementable_version() {
  local version="$1"
  local major
  local minor
  local patch

  [[ "$version" =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]] || \
    fail "VERSION must use numeric major.minor.patch format, got: $version"

  IFS=. read -r major minor patch <<EOF
$version
EOF
}

next_patch_version() {
  local current="$1"
  local major
  local minor
  local patch

  assert_incrementable_version "$current"

  IFS=. read -r major minor patch <<EOF
$current
EOF

  printf '%s.%s.%s\n' "$major" "$minor" "$((10#$patch + 1))"
}

resolve_release_version() {
  local requested="${1:-}"

  if [ -n "$requested" ]; then
    assert_incrementable_version "$requested"
    printf '%s\n' "$requested"
    return
  fi

  next_patch_version "$(current_image_version)"
}

write_image_version() {
  local version="$1"

  assert_incrementable_version "$version"
  printf '%s\n' "$version" > "$VERSION_FILE"
}
