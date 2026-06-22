#!/bin/sh
set -eu

log() {
  echo "[cli-persistent-config] $*"
}

fail() {
  echo "[cli-persistent-config] ERROR: $*" >&2
  exit 1
}

write_profile_hook() {
  cat > /etc/profile.d/cli-persistent-config.sh <<'EOF'
#!/bin/sh

USER_HOME="${HOME:-/home/$(whoami)}"

link_config() {
  home_rel="$1"
  target="$2"
  home_abs="${USER_HOME}/${home_rel}"

  if [ -L "${home_abs}" ]; then
    return 0
  fi

  if [ -e "${home_abs}" ]; then
    if [ -d "${home_abs}" ] && [ ! -L "${home_abs}" ]; then
      if [ -z "$(ls -A "${target}" 2>/dev/null)" ]; then
        if cp -a "${home_abs}/." "${target}/"; then
          rm -rf "${home_abs}"
        else
          echo "[cli-persistent-config] WARNING: Failed to copy existing configuration from ${home_abs} to ${target}. Skipping symlink creation to prevent data loss." >&2
          return 1
        fi
      else
        mv "${home_abs}" "${home_abs}.bak-$(date +%s)"
      fi
    else
      rm -f "${home_abs}"
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

  chmod +x /etc/profile.d/cli-persistent-config.sh
}

main() {
  log "Activating feature 'cli-persistent-config'"

  CONTAINER_USER="${_CONTAINER_USER:-node}"

  mkdir -p /var/lib/agent-configs
  chown -R "${CONTAINER_USER}:${CONTAINER_USER}" /var/lib/agent-configs
  chmod 777 /var/lib/agent-configs

  for tool in claude gemini crush copilot opencode codex superpowers; do
    mkdir -p "/var/lib/agent-configs/${tool}"
    chown -R "${CONTAINER_USER}:${CONTAINER_USER}" "/var/lib/agent-configs/${tool}"
    chmod -R 777 "/var/lib/agent-configs/${tool}"
  done

  log "Writing profile startup hook"
  write_profile_hook

  # Clean up apt cache per repository guidelines
  rm -rf /var/lib/apt/lists/*

  log "CLI Persistent Config installation complete"
}

main "$@"
