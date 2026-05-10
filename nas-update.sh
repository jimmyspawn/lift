#!/bin/bash
# Update the Lift deploy on the Ugreen NAS.
#
# UGOS gotchas this handles:
#   - No `git` binary in PATH → use the `alpine/git` Docker image instead.
#   - UGOS extended ACLs (the `+` in `ls -la`) override Unix perms and block
#     reads from inside containers → strip them and reset clean perms.
#
# Usage (from the NAS):
#   sudo /volume1/docker/lift/nas-update.sh

set -euo pipefail

LIFT_DIR="/volume1/docker/lift"

if [ ! -d "$LIFT_DIR" ]; then
  echo "Error: $LIFT_DIR does not exist. Clone the repo there first."
  exit 1
fi

echo "→ Pulling latest from origin…"
# `-c safe.directory=/work` — alpine/git runs as root, but the repo files
# are owned by uid 1000, which trips git's dubious-ownership safety check.
docker run --rm -v "$LIFT_DIR":/work -w /work alpine/git -c safe.directory=/work pull

echo "→ Stripping UGOS ACLs and resetting perms on public/…"
setfacl -R -b "$LIFT_DIR/public"
chmod -R a+rX "$LIFT_DIR/public"

echo "✓ Lift updated. Reload the app to pick up changes."
