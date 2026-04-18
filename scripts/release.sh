#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
. "$SCRIPT_DIR/lib.sh"

usage() {
  printf '%s\n' 'usage: scripts/release.sh IMAGE [VERSION]' >&2
  exit 2
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage

IMAGE="$1"
VERSION="${2:-}"

load_dotenv
load_image_config "$IMAGE"
require_command docker
VERSION="$(resolve_release_version "$VERSION")"
append_tag_flags "$VERSION"
append_build_arg_flags
append_cache_flags

printf 'Building and pushing %s:%s for %s\n' "$IMAGE" "$VERSION" "$PLATFORMS"
docker buildx build \
  --push \
  --platform "$PLATFORMS" \
  -f "$ROOT_DIR/$DOCKERFILE" \
  "${CACHE_FLAGS[@]}" \
  "${BUILD_ARG_FLAGS[@]}" \
  "${TAG_FLAGS[@]}" \
  "$ROOT_DIR/$CONTEXT"

write_image_version "$VERSION"
printf 'Recorded %s as the current version for %s\n' "$VERSION" "$IMAGE"
