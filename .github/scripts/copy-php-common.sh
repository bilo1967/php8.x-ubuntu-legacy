#!/usr/bin/env bash
set -Eeuo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
destination=${1:?Destination directory required}
source_dir="$repo/vendor/php-common"
(cd "$source_dir" && sha256sum -c SHA256SUMS)
file="$source_dir/php-common.deb"
[[ $(dpkg-deb -f "$file" Package) == php-common ]]
[[ $(dpkg-deb -f "$file" Version) == '2:101+0~20261021.78+ubuntu22.04~1.gbp53f25f' ]]
[[ $(dpkg-deb -f "$file" Architecture) == all ]]
mkdir -p "$destination"
cp "$file" "$destination/php-common_101+0~20261021.78+ubuntu22.04~1.gbp53f25f_all.deb"
