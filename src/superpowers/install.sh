#!/bin/sh
set -eu
export DEBIAN_FRONTEND=noninteractive
log() {
  echo "[superpowers] $*"
}
fail() {
  echo "[superpowers] ERROR: $*" >&2
  exit 1
}
apt_install() {
  apt-get update
  apt-get install -y --no-install-recommends "$@"
}
write_init_helper() {
  cat > /usr/local/bin/superpowers-init-workspace <<'EOF'
#!/bin/sh
set -eu
USER_HOME="${HOME:-/home/$(whoami)}"
link_target() {
  src="$1"
  dest="$2"
  if [ ! -e "${src}" ]; then
    return 0
  fi
  if [ -L "${dest}" ]; then
    return 0
  fi
  if [ -d "${dest}" ]; then
    for item in "${src}"/*; do
      [ -e "${item}" ] || continue
      ln -s "${item}" "${dest}/$(basename "${item}")" 2>/dev/null || true
    done
    return 0
  fi
  if [ -e "${dest}" ]; then
    mv "${dest}" "${dest}.bak-$(date +%s)" 2>/dev/null || rm -f "${dest}"
  fi
  mkdir -p "$(dirname "${dest}")"
  ln -s "${src}" "${dest}"
}
link_target "/usr/local/share/superpowers" "${USER_HOME}/.claude/plugins/superpowers"
WORKSPACE_DIR="$PWD"
if [ -d "${WORKSPACE_DIR}/.git" ] || [ -d "${WORKSPACE_DIR}/.devcontainer" ] || [ -f "${WORKSPACE_DIR}/devcontainer.json" ]; then
  link_target "/usr/local/share/superpowers/skills" "${WORKSPACE_DIR}/.gemini/skills"
  link_target "/usr/local/share/superpowers/commands" "${WORKSPACE_DIR}/.gemini/commands"
  link_target "/usr/local/share/superpowers/skills" "${WORKSPACE_DIR}/.github/skills"
  link_target "/usr/local/share/superpowers/prompts" "${WORKSPACE_DIR}/.github/prompts"
  link_target "/usr/local/share/superpowers/skills" "${WORKSPACE_DIR}/.opencode/skills"
  link_target "/usr/local/share/superpowers/commands" "${WORKSPACE_DIR}/.opencode/command"
fi
EOF
  chmod +x /usr/local/bin/superpowers-init-workspace
}
write_profile_hook() {
  cat > /etc/profile.d/superpowers-init-workspace.sh <<'EOF'
#!/bin/sh
if [ -t 1 ] && command -v superpowers-init-workspace >/dev/null 2>&1; then
  superpowers-init-workspace >/dev/null 2>&1 || true
fi
EOF
  chmod +x /etc/profile.d/superpowers-init-workspace.sh
}
main() {
  log "Activating feature 'superpowers'"
  log "Installing prerequisites (git, ca-certificates)"
  apt_install git ca-certificates
  log "Cloning Superpowers repository"
  rm -rf /usr/local/share/superpowers
  git clone --depth 1 https://github.com/obra/superpowers.git /usr/local/share/superpowers
  log "Writing initialization helpers"
  write_init_helper
  write_profile_hook
  log "Cleaning up apt cache"
  rm -rf /var/lib/apt/lists/*
  log "Superpowers feature installation complete"
}
main "$@"
