#!/bin/sh
set -eu
export DEBIAN_FRONTEND=noninteractive
log() {
  echo "[antigravity-cli] $*"
}
fail() {
  echo "[antigravity-cli] ERROR: $*" >&2
  exit 1
}
apt_install() {
  apt-get update
  apt-get install -y --no-install-recommends "$@"
}
main() {
  log "Activating feature 'antigravity-cli'"
  log "Installing prerequisites"
  apt_install ca-certificates curl gnupg2 tar bash
  log "Downloading and running official installer"
  curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- -d /usr/local/bin
  command -v agy >/dev/null 2>&1 || fail "agy CLI was not added to PATH."
  agy --help >/dev/null 2>&1 || fail "agy CLI failed to execute."
  log "Cleaning up apt cache"
  rm -rf /var/lib/apt/lists/*
  log "Antigravity CLI installation complete"
}
main "$@"
