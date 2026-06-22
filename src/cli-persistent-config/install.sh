#!/bin/sh
set -eu

log() {
  echo "[cli-persistent-config] $*"
}

fail() {
  echo "[cli-persistent-config] ERROR: $*" >&2
  exit 1
}

write_init_helper() {
  cat > /usr/local/bin/cli-persistent-config-init <<'EOF'
#!/bin/sh
set -eu
USER_HOME="${HOME:-/home/$(whoami)}"

link_config() {
  home_rel="$1"
  target="$2"
  home_abs="${USER_HOME}/${home_rel}"

  if [ -L "${home_abs}" ]; then
    return 0
  fi

  # Safe write permission check
  if [ ! -w "${target}" ] && [ ! -w "$(dirname "${target}")" ]; then
    echo "[cli-persistent-config] WARNING: Target path '${target}' is not writable. Skipping." >&2
    return 0
  fi

  if [ -e "${home_abs}" ]; then
    if [ -d "${home_abs}" ] && [ ! -L "${home_abs}" ]; then
      if [ -z "$(ls -A "${target}" 2>/dev/null)" ]; then
        if ! cp -a "${home_abs}/." "${target}/" 2>/dev/null; then
          echo "[cli-persistent-config] ERROR: Failed to migrate '${home_abs}' to '${target}'. Skipping symlink." >&2
          return 1
        fi
      else
        cp -an "${home_abs}/." "${target}/" 2>/dev/null || true
      fi
      mv "${home_abs}" "${home_abs}.bak-$(date +%s)"
    else
      mv "${home_abs}" "${home_abs}.bak-$(date +%s)"
    fi
  fi

  mkdir -p "$(dirname "${home_abs}")"
  ln -s "${target}" "${home_abs}"
}

link_config ".claude" "/var/lib/agent-configs/claude"
link_config ".gemini" "/var/lib/agent-configs/gemini"
link_config ".crush" "/var/lib/agent-configs/crush"
link_config ".config/github-copilot" "/var/lib/agent-configs/copilot"
link_config ".opencode" "/var/lib/agent-configs/opencode"
link_config ".codex" "/var/lib/agent-configs/codex"
link_config ".config/superpowers" "/var/lib/agent-configs/superpowers"
EOF
  chmod +x /usr/local/bin/cli-persistent-config-init
}

write_profile_hook() {
  cat > /etc/profile.d/cli-persistent-config.sh <<'EOF'
#!/bin/sh
if command -v cli-persistent-config-init >/dev/null 2>&1; then
  cli-persistent-config-init >/dev/null 2>&1 || true
fi
EOF
  chmod +x /etc/profile.d/cli-persistent-config.sh
}

main() {
  log "Activating feature 'cli-persistent-config'"

  # Robust container user resolution based on standard UID 1000 or env fallbacks
  if [ -z "${_CONTAINER_USER:-}" ] || [ "${_CONTAINER_USER}" = "root" ]; then
    CONTAINER_USER=$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)
    CONTAINER_USER="${CONTAINER_USER:-${_REMOTE_USER:-root}}"
  else
    CONTAINER_USER="${_CONTAINER_USER}"
  fi

  log "Configuring system paths and permissions for user: ${CONTAINER_USER}"
  mkdir -p /var/lib/agent-configs
  chown -R "${CONTAINER_USER}:${CONTAINER_USER}" /var/lib/agent-configs 2>/dev/null || true
  chmod 700 /var/lib/agent-configs

  for tool in claude gemini crush copilot opencode codex superpowers; do
    mkdir -p "/var/lib/agent-configs/${tool}"
    chown -R "${CONTAINER_USER}:${CONTAINER_USER}" "/var/lib/agent-configs/${tool}" 2>/dev/null || true
    chmod -R 700 "/var/lib/agent-configs/${tool}"
  done

  log "Writing initialization binaries and hooks"
  write_init_helper
  write_profile_hook

  # Clean up apt cache per repository guidelines
  rm -rf /var/lib/apt/lists/*

  log "CLI Persistent Config installation complete"
}

main "$@"
