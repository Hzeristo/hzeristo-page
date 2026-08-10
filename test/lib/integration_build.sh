#!/usr/bin/env bash
# Build a Jekyll site for integration tests: copy the starter into a temp
# source tree and inject CI-only demo posts from test/fixtures/posts/.
#
# Usage (from repo root, after setting INTEGRATION_TMP_DIR):
#   source test/lib/integration_build.sh
#   integration_build "${site_out}" --config "_config.yml,${override}"
set -euo pipefail

integration_build() {
  local site_out="$1"
  shift

  if [ -z "${INTEGRATION_TMP_DIR:-}" ]; then
    echo "INTEGRATION_TMP_DIR must be set before calling integration_build" >&2
    exit 1
  fi

  local site_src="${INTEGRATION_TMP_DIR}/site-src"
  mkdir -p "${site_src}"

  rsync -a \
    --exclude='.git' \
    --exclude='_site' \
    --exclude='vendor' \
    --exclude='node_modules' \
    ./ "${site_src}/"

  cp test/fixtures/posts/*.md "${site_src}/_posts/"

  (
    cd "${site_src}"
    bundle exec jekyll build "$@" -d "${site_out}"
  ) >/dev/null
}
