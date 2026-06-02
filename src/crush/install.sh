#!/bin/sh
set -eu

export DEBIAN_FRONTEND=noninteractive

CHARM_GPG_KEY_URL="https://repo.charm.sh/apt/gpg.key"
CHARM_REPO_URL="https://repo.charm.sh/apt"
CHARM_REPO_NAME="charm"

log() {
  echo "[crush] $*"
}

fail() {
  echo "[crush] ERROR: $*" >&2
  exit 1
}

apt_install() {
  apt-get update
  apt-get install -y --no-install-recommends "$@"
}

main() {
  log "Activating feature 'crush'"

  version="${VERSION:-latest}"
  
  # Setup Charm apt repository
  log "Setting up Charm apt repository"
  apt_install ca-certificates curl gnupg

  mkdir -p /etc/apt/keyrings
  curl -fsSL "${CHARM_GPG_KEY_URL}" | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  chmod a+r /etc/apt/keyrings/charm.gpg

  printf 'deb [signed-by=/etc/apt/keyrings/charm.gpg] %s * *\n' "${CHARM_REPO_URL}" \
    > /etc/apt/sources.list.d/charm.list

  # Install crush
  log "Installing Crush (version: ${version})"
  if [ "${version}" = "latest" ]; then
    apt_install crush
  else
    apt_install "crush=${version}"
  fi

  # Verify installation
  command -v crush >/dev/null 2>&1 || fail "Crush CLI was not added to PATH."

  # Cleanup
  log "Cleaning up apt cache"
  rm -rf /var/lib/apt/lists/*

  log "Crush installation complete"
}

main "$@"
