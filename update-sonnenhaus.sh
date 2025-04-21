#! /usr/bin/env bash

# usage:
# update_api.sh <payload> <release_versions_folder> <path_to_firebease_cfg> <path_to_delivery>

set -euo pipefail

release_url="$("${1}" | jq -r ".release.url")"
release_id="$("${1}" | jq -r ".release.id")"
target_dir="${2}/${release_id}"
content_dir="${target_dir}/dist"
download_url="$(curl "${release_url}" | jq -r ".assets[0].browser_download_url")"

curl "${download_url}" -L --output "${2}/release.tar"
mkdir "${target_dir}"
tar -xf "${2}/release.tar" -C "${target_dir}"

ln -sf "${3}" "${content_dir}/assets/firebase_cfg.json"
ln -sf "${content_dir}" "${4}"
