#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
. "$SCRIPT_DIR/lib.sh"

usage() {
  printf '%s\n' 'usage: scripts/scan.sh IMAGE VERSION' >&2
  exit 2
}

[ "$#" -eq 2 ] || usage

IMAGE="$1"
VERSION="$2"

load_dotenv
load_image_config "$IMAGE"
require_command docker

SEVERITY="${SEVERITY:-HIGH,CRITICAL}"
IGNORE_UNFIXED="${IGNORE_UNFIXED:-1}"
SCANNER_IMAGE="${SCANNER_IMAGE:-aquasec/trivy:latest}"
SCAN_EXIT_CODE="${SCAN_EXIT_CODE:-0}"

scan_dir="$ROOT_DIR/tmp/scans"
mkdir -p "$scan_dir"

repo="$(image_repository)"
image_ref="$repo:$VERSION"
safe_ref="${repo//\//_}-$VERSION"
json_report="$scan_dir/$safe_ref-trivy.json"

ignore_flags=()
case "$IGNORE_UNFIXED" in
  1|true|TRUE|yes|YES) ignore_flags+=("--ignore-unfixed") ;;
esac

printf 'Scanning %s with %s\n' "$image_ref" "$SCANNER_IMAGE"
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$scan_dir:/scan" \
  "$SCANNER_IMAGE" image \
  --scanners vuln \
  --severity "$SEVERITY" \
  --exit-code "$SCAN_EXIT_CODE" \
  "${ignore_flags[@]}" \
  --no-progress \
  --format json \
  -o "/scan/$(basename "$json_report")" \
  "$image_ref"

printf 'Wrote %s\n' "$json_report"

if command -v jq >/dev/null 2>&1; then
  printf '\nSummary by severity:\n'
  jq -r '
    [.Results[]?.Vulnerabilities[]?]
    | if length == 0 then
        "  none"
      else
        group_by(.Severity)
        | map("  " + .[0].Severity + ": " + (length|tostring))
        | .[]
      end
  ' "$json_report"

  printf '\nTop affected packages:\n'
  jq -r '
    [.Results[]?.Vulnerabilities[]? | {pkg:.PkgName, installed:.InstalledVersion, fixed:.FixedVersion, severity:.Severity}]
    | if length == 0 then
        "  none"
      else
        group_by(.pkg + "\u0000" + .installed)
        | map({
            pkg: .[0].pkg,
            installed: .[0].installed,
            count: length,
            severities: ([.[].severity] | unique | join(",")),
            fixed: ([.[].fixed] | unique | join(", "))
          })
        | sort_by(-.count)
        | .[:10]
        | .[]
        | "  " + (.count|tostring) + " " + .severities + " " + .pkg + "@" + .installed + " fixed: " + .fixed
      end
  ' "$json_report"
else
  printf 'Install jq for a local summary, or inspect %s directly.\n' "$json_report"
fi
