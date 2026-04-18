#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
. "$SCRIPT_DIR/lib.sh"

usage() {
  printf '%s\n' 'usage: scripts/tags.sh IMAGE [VERSION]' >&2
  exit 2
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage

IMAGE="$1"
VERSION="${2:-}"

load_dotenv
load_image_config "$IMAGE"
VERSION="$(resolve_release_version "$VERSION")"
all_tags "$VERSION"
