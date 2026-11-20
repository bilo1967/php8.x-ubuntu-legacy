#!/usr/bin/env bash
# Stage an existing successful core build; never rebuild PHP or PECL here.
set -Eeuo pipefail
: "${REPO:?}" "${RUN_ID:?}" "${TAG:?}" "${BRANCH:?}" "${GH_TOKEN:?}"
mode=${1:-attach}
[[ "$mode" == attach || "$mode" == stage ]] || exit 1
[[ "$RUN_ID" =~ ^[0-9]+$ ]] || { echo 'Invalid run ID'; exit 1; }
if [[ "$TAG" =~ ^v(8\.[0-9]+)\.([0-9]+)-focal\.[0-9]+$ ]]; then
  minor=${BASH_REMATCH[1]}
  version="$minor.${BASH_REMATCH[2]}"
else
  echo "Invalid core release tag: $TAG"; exit 1
fi
case "$minor:$BRANCH" in
  8.3:main|8.4:php84) ;;
  *) echo "Unsupported PHP/branch combination: $minor/$BRANCH"; exit 1 ;;
esac
run=$(gh api "repos/$REPO/actions/runs/$RUN_ID")
jq -e --arg branch "$BRANCH" '
  .status == "completed" and .conclusion == "success" and
  .head_branch == $branch and .path == ".github/workflows/build.yml"
' <<< "$run" > /dev/null
source_sha=$(jq -r .head_sha <<< "$run")
notes="releases/$TAG.md"
test -s "$notes"
if [[ "$mode" == attach ]]; then
  [[ $(gh release view "$TAG" --repo "$REPO" --json isDraft --jq .isDraft) == true ]]

fi
mkdir -p artifacts/core release-assets
[[ -z $(find release-assets -mindepth 1 -print -quit) ]] || { echo 'Staging directory must be empty'; exit 1; }
gh run download "$RUN_ID" --repo "$REPO" --name "php${minor}-ubuntu20.04-amd64" --dir artifacts/core
test -s artifacts/core/SHA256SUMS
test -s artifacts/core/source-files.sha256
(cd artifacts/core && sha256sum -c SHA256SUMS)
shopt -s nullglob
packages=(artifacts/core/*.deb)
(( ${#packages[@]} >= 30 )) || { echo 'Too few core packages'; exit 1; }
# Require manifest coverage for every package, not just checksum validity of listed files.
(cd artifacts/core && sha256sum ./*.deb | LC_ALL=C sort) > artifacts/computed.sha256
LC_ALL=C sort artifacts/core/SHA256SUMS > artifacts/expected.sha256
cmp artifacts/computed.sha256 artifacts/expected.sha256
for required in cli fpm common ldap; do
  matches=(artifacts/core/php"$minor"-"$required"_*.deb)
  (( ${#matches[@]} == 1 )) || { echo "Missing/duplicate $required"; exit 1; }
done
declare -A seen=()
shared_common=0
for file in "${packages[@]}"; do
  package=$(dpkg-deb -f "$file" Package)
  package_version=$(dpkg-deb -f "$file" Version)
  architecture=$(dpkg-deb -f "$file" Architecture)
  [[ "$architecture" == amd64 || "$architecture" == all ]] || exit 1
  [[ ! -v "seen[$package]" ]] || { echo "Duplicate package $package"; exit 1; }
  seen[$package]=1
  if [[ "$package" == php-common && "$minor" == 8.4 ]]; then
    [[ "$architecture" == all ]]
    [[ "$package_version" == '2:101+0~20261021.78+ubuntu22.04~1.gbp53f25f' ]]
    echo "62bc3fbedea25bb92869c60085f094bcb68716e3ddb8c3128eb33a977f697a05  $file" | sha256sum -c -
    shared_common=$((shared_common + 1))
  else
    case "$package" in
      php"$minor"|php"$minor"-*|libapache2-mod-php"$minor"|libphp"$minor"-embed) ;;
      *) echo "Unexpected package $package"; exit 1 ;;
    esac
    [[ "$package_version" == "$version-"*+legacy*~ubuntu20.04 ]] || {
      echo "Version $package_version does not match release $TAG"; exit 1;
    }
  fi
  # GitHub removes '~' from asset names. Normalize before hashing, without changing .deb contents.
  name=${file##*/}
  name=${name//\~/}
  [[ ! -e "release-assets/$name" ]] || { echo "Duplicate filename $name"; exit 1; }
  cp -- "$file" "release-assets/$name"
done
[[ "$minor" != 8.4 || "$shared_common" == 1 ]]
cp artifacts/core/source-files.sha256 release-assets/
printf 'Build run: https://github.com/%s/actions/runs/%s\nSource commit: %s\n' "$REPO" "$RUN_ID" "$source_sha" > release-assets/BUILD-ORIGIN.txt
(cd release-assets && sha256sum ./*.deb > SHA256SUMS && sha256sum -c SHA256SUMS)
cp "$notes" artifacts/release-notes.md
printf '\n## Build provenance\n\nPackages: https://github.com/%s/actions/runs/%s (commit `%s`).\n' "$REPO" "$RUN_ID" "$source_sha" >> artifacts/release-notes.md
cp artifacts/release-notes.md release-assets/RELEASE-NOTES.md
if [[ "$mode" == attach ]]; then
  gh release upload "$TAG" release-assets/* --repo "$REPO"
  echo "Attached ${#packages[@]} Debian packages to draft $TAG; draft remains unpublished."
else
  echo "Prepared $TAG with ${#packages[@]} Debian packages for download; no release was created."
fi
