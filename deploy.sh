#!/bin/bash
# Deploy Lift to the NAS from this Mac: push, then run the root-owned copy of
# nas-update.sh on the NAS (/volume1/docker/lift-deploy.sh, passwordless via
# /etc/sudoers.d/lift-deploy). If nas-update.sh changes, refresh that copy:
#   sudo install -o root -g root -m 755 /volume1/docker/lift/nas-update.sh /volume1/docker/lift-deploy.sh
set -euo pipefail
git -C "$(dirname "$0")" push
# UGOS auto-disables SSH after a while — fail fast with a hint instead of hanging.
ssh -i ~/.ssh/lift_nas -o ConnectTimeout=8 JimmyAdmin@192.168.86.23 'sudo -n /volume1/docker/lift-deploy.sh' || {
  echo "✗ NAS deploy failed. Is SSH enabled? (UGOS → Control Panel → Terminal — it auto-disables after a while)" >&2
  exit 1
}
