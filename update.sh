#! /usr/bin/env bash

# usage:
# update_api.sh <payload> <path_to_local_api_repo> <branch_name> <systemd-unit-name>

set -euo pipefail

git \
  -C "${2}" \
  pull origin "${3}" --rebase

sudo systemctl restart "${4}"
