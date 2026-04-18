#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  printf '%s\n' 'usage: scripts/new-image.sh IMAGE [BASE]' >&2
  exit 2
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage

IMAGE="$1"
BASE="${2:-alpine:latest}"

case "$IMAGE" in
  ''|*[^a-z0-9._-]*)
    printf '%s\n' 'image names may only contain lowercase letters, numbers, dots, underscores, and dashes' >&2
    exit 2
    ;;
esac

IMAGE_DIR="$ROOT_DIR/images/$IMAGE"
[ ! -e "$IMAGE_DIR" ] || { printf 'image folder already exists: images/%s\n' "$IMAGE" >&2; exit 1; }

mkdir -p "$IMAGE_DIR"

cat > "$IMAGE_DIR/Dockerfile" <<EOF
FROM $BASE

ARG IMAGE_VERSION=dev
LABEL org.opencontainers.image.version="\${IMAGE_VERSION}"

CMD ["sh"]
EOF

cat > "$IMAGE_DIR/.dockerignore" <<'EOF'
.git
.DS_Store
*.log
tmp/
EOF

cat > "$IMAGE_DIR/image.env" <<EOF
IMAGE_NAME=$IMAGE
CONTEXT=images/$IMAGE
DOCKERFILE=images/$IMAGE/Dockerfile
PLATFORMS=linux/amd64,linux/arm64
DEFAULT_TAGS=
BUILD_ARGS=
EOF

cat > "$IMAGE_DIR/VERSION" <<'EOF'
0.0.0
EOF

cat > "$IMAGE_DIR/README.md" <<EOF
# $IMAGE

## Build

\`\`\`sh
make build IMAGE=$IMAGE VERSION=0.1.0
\`\`\`

## Release

\`\`\`sh
make release IMAGE=$IMAGE TAGS=latest
\`\`\`
EOF

printf 'created images/%s\n' "$IMAGE"
