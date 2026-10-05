#!/bin/bash
# Deploy Lift to the NAS from this Mac: push, then run the root-owned copy of
# nas-update.sh on the NAS (/volume1/docker/lift-deploy.sh, passwordless via
# /etc/sudoers.d/lift-deploy). If nas-update.sh changes, refresh that copy:
#   sudo install -o root -g root -m 755 /volume1/docker/lift/nas-update.sh /volume1/docker/lift-deploy.sh
set -euo pipefail
git -C "$(dirname "$0")" push
ssh -i ~/.ssh/lift_nas JimmyAdmin@192.168.86.23 'sudo -n /volume1/docker/lift-deploy.sh'
