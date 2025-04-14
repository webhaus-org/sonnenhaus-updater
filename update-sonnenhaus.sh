#! /usr/bin/env bash

# usage:
# update_api.sh <path_to_local_repo> <branch_name> <path_to_env> <path_to_firebase-config> <out_dir>

set -euo pipefail

git \
  -C "${1}" \
  pull origin "${2}" --rebase

npm --prefix "${1}" install "${1}"
ln -sf "${3}" "${1}"/.env #env
ln -sf "${4}" "${1}"/src/firebase_config.json #firebase_config

vite build "${1}" --outDir "${5}" --mode production
