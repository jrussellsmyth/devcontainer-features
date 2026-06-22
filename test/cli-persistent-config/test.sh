#!/bin/bash
set -e
source dev-container-features-test-lib

check "profile hook exists" bash -lc "[ -f /etc/profile.d/cli-persistent-config.sh ]"
check "cli-persistent-config-init is executable" bash -lc "[ -x /usr/local/bin/cli-persistent-config-init ]"

# Run the initialization helper to create links
bash -lc "cli-persistent-config-init"

# Helper to verify link target and write permission
verify_link() {
  local link_path="$1"
  local expected_target="$2"
  
  # 1. Check if it is a symlink
  if [ ! -L "${link_path}" ]; then
    echo "Error: ${link_path} is not a symbolic link." >&2
    return 1
  fi
  
  # 2. Check if it points to the correct target
  local actual_target
  actual_target="$(readlink "${link_path}")"
  if [ "${actual_target}" != "${expected_target}" ]; then
    echo "Error: ${link_path} points to ${actual_target}, expected ${expected_target}." >&2
    return 1
  fi
  
  # 3. Check write access
  if ! touch "${link_path}/.test-write" 2>/dev/null; then
    echo "Error: ${link_path} is not writable." >&2
    return 1
  fi
  rm -f "${link_path}/.test-write"
  return 0
}

export -f verify_link

check "claude configuration symlinked correctly" bash -lc "verify_link ~/.claude /var/lib/agent-configs/claude"
check "gemini configuration symlinked correctly" bash -lc "verify_link ~/.gemini /var/lib/agent-configs/gemini"
check "crush configuration symlinked correctly" bash -lc "verify_link ~/.crush /var/lib/agent-configs/crush"
check "copilot configuration symlinked correctly" bash -lc "verify_link ~/.config/github-copilot /var/lib/agent-configs/copilot"
check "opencode configuration symlinked correctly" bash -lc "verify_link ~/.opencode /var/lib/agent-configs/opencode"
check "codex configuration symlinked correctly" bash -lc "verify_link ~/.codex /var/lib/agent-configs/codex"
check "superpowers configuration symlinked correctly" bash -lc "verify_link ~/.config/superpowers /var/lib/agent-configs/superpowers"

reportResults
