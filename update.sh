#! /usr/bin/env bash

# usage:
# update_api.sh <path_to_local_api_repo> <branch_name> <systemd-unit-name>

set -euo pipefail

git \
  -C "${1}" \
  pull origin "${2}" --rebase

sudo systemctl restart "${3}"
