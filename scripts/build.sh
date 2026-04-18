#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
. "$SCRIPT_DIR/lib.sh"

usage() {
  printf '%s\n' 'usage: scripts/build.sh IMAGE VERSION' >&2
  exit 2
}

[ "$#" -eq 2 ] || usage

IMAGE="$1"
VERSION="$2"

load_dotenv
load_image_config "$IMAGE"
require_command docker
append_tag_flags "$VERSION"
append_build_arg_flags

BUILD_PLATFORM="${BUILD_PLATFORM:-${PLATFORMS%%,*}}"

printf 'Building %s for %s\n' "$IMAGE" "$BUILD_PLATFORM"
docker buildx build \
  --load \
  --platform "$BUILD_PLATFORM" \
  -f "$ROOT_DIR/$DOCKERFILE" \
  "${BUILD_ARG_FLAGS[@]}" \
  "${TAG_FLAGS[@]}" \
  "$ROOT_DIR/$CONTEXT"
