#!/bin/sh
set -eu

export DEBIAN_FRONTEND=noninteractive

OPEN_SPEC_PACKAGE="@fission-ai/openspec@latest"
NODE_MAJOR_VERSION="22"
SUPPORTED_TOOLS="amazon-q antigravity auggie claude cline codex codebuddy continue costrict crush cursor factory gemini github-copilot iflow kilocode kiro opencode pi qoder qwen roocode trae windsurf"
CONFIG_DIR="/usr/local/etc"
CONFIG_FILE="${CONFIG_DIR}/openspec-devcontainer.conf"
PROFILE_HOOK="/etc/profile.d/openspec-init-workspace.sh"

log() {
  echo "[openspec-feature] $*"
}

fail() {
  echo "[openspec-feature] ERROR: $*" >&2
  exit 1
}

trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

normalize_tool_support() {
  raw_value="$(trim "$1")"

  if [ -z "${raw_value}" ] || [ "${raw_value}" = "none" ]; then
    printf 'none\n'
    return 0
  fi

  if [ "${raw_value}" = "all" ]; then
    printf '%s\n' "$(printf '%s' "${SUPPORTED_TOOLS}" | tr ' ' ',')"
    return 0
  fi

  normalized=""
  old_ifs="${IFS}"
  IFS=','
  set -- ${raw_value}
  IFS="${old_ifs}"

  for tool_candidate in "$@"; do
    tool="$(trim "${tool_candidate}")"
    [ -n "${tool}" ] || continue

    supported=0
    for supported_tool in ${SUPPORTED_TOOLS}; do
      if [ "${supported_tool}" = "${tool}" ]; then
        supported=1
        break
      fi
    done

    if [ "${supported}" -ne 1 ]; then
      fail "Unsupported toolSupport value '${tool}'. Supported values: none, all, or a comma-separated list of ${SUPPORTED_TOOLS}."
    fi

    case ",${normalized}," in
      *,"${tool}",*) ;;
      *)
        if [ -n "${normalized}" ]; then
          normalized="${normalized},${tool}"
        else
          normalized="${tool}"
        fi
        ;;
    esac
  done

  if [ -z "${normalized}" ]; then
    printf 'none\n'
  else
    printf '%s\n' "${normalized}"
  fi
}

node_is_usable() {
  command -v node >/dev/null 2>&1 || return 1
  command -v npm >/dev/null 2>&1 || return 1

  node - <<'EOF'
const [major, minor, patch] = process.versions.node.split('.').map(Number);
const supported =
  major > 20 ||
  (major === 20 && (minor > 19 || (minor === 19 && patch >= 0)));
process.exit(supported ? 0 : 1);
EOF
}

apt_install() {
  apt-get update
  apt-get install -y --no-install-recommends "$@"
}

install_node() {
  log "Installing Node.js ${NODE_MAJOR_VERSION}.x because a usable Node runtime was not detected."
  apt_install ca-certificates curl gnupg

  mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  chmod a+r /etc/apt/keyrings/nodesource.gpg

  printf 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_%s.x nodistro main\n' "${NODE_MAJOR_VERSION}" \
    > /etc/apt/sources.list.d/nodesource.list

  apt-get update
  apt-get install -y --no-install-recommends nodejs
  rm -rf /var/lib/apt/lists/*
}

write_tool_support_helper() {
  cat > /usr/local/bin/openspec-feature-tool-support <<'EOF'
#!/bin/sh
set -eu

SUPPORTED_TOOLS="amazon-q antigravity auggie claude cline codex codebuddy continue costrict crush cursor factory gemini github-copilot iflow kilocode kiro opencode pi qoder qwen roocode trae windsurf"
CONFIG_FILE="/usr/local/etc/openspec-devcontainer.conf"

trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

fail() {
  echo "[openspec-feature] ERROR: $*" >&2
  exit 1
}

normalize_tool_support() {
  raw_value="$(trim "$1")"

  if [ -z "${raw_value}" ] || [ "${raw_value}" = "none" ]; then
    printf 'none\n'
    return 0
  fi

  if [ "${raw_value}" = "all" ]; then
    printf '%s\n' "$(printf '%s' "${SUPPORTED_TOOLS}" | tr ' ' ',')"
    return 0
  fi

  normalized=""
  old_ifs="${IFS}"
  IFS=','
  set -- ${raw_value}
  IFS="${old_ifs}"

  for tool_candidate in "$@"; do
    tool="$(trim "${tool_candidate}")"
    [ -n "${tool}" ] || continue

    supported=0
    for supported_tool in ${SUPPORTED_TOOLS}; do
      if [ "${supported_tool}" = "${tool}" ]; then
        supported=1
        break
      fi
    done

    if [ "${supported}" -ne 1 ]; then
      fail "Unsupported toolSupport value '${tool}'. Supported values: none, all, or a comma-separated list of ${SUPPORTED_TOOLS}."
    fi

    case ",${normalized}," in
      *,"${tool}",*) ;;
      *)
        if [ -n "${normalized}" ]; then
          normalized="${normalized},${tool}"
        else
          normalized="${tool}"
        fi
        ;;
    esac
  done

  if [ -z "${normalized}" ]; then
    printf 'none\n'
  else
    printf '%s\n' "${normalized}"
  fi
}

command_name="${1:-current}"

case "${command_name}" in
  current)
    . "${CONFIG_FILE}"
    printf '%s\n' "${OPENSPEC_FEATURE_TOOL_SUPPORT:-none}"
    ;;
  normalize)
    shift
    normalize_tool_support "${1:-none}"
    ;;
  *)
    echo "Usage: openspec-feature-tool-support [current|normalize <value>]" >&2
    exit 2
    ;;
esac
EOF

  chmod +x /usr/local/bin/openspec-feature-tool-support
}

write_workspace_init_helper() {
  cat > /usr/local/bin/openspec-init-workspace <<'EOF'
#!/bin/sh
set -eu

CONFIG_FILE="/usr/local/etc/openspec-devcontainer.conf"

log() {
  echo "[openspec-feature] $*"
}

fail() {
  echo "[openspec-feature] ERROR: $*" >&2
  exit 1
}

[ -r "${CONFIG_FILE}" ] || fail "Missing feature configuration at ${CONFIG_FILE}."
. "${CONFIG_FILE}"

TOOLS="${OPENSPEC_FEATURE_TOOL_SUPPORT:-none}"
TARGET_INPUT="${1:-$PWD}"

TARGET_DIR="$(cd "${TARGET_INPUT}" 2>/dev/null && pwd)" || fail "Unable to access workspace path '${TARGET_INPUT}'."

if [ "${TOOLS}" = "none" ]; then
  log "toolSupport=none; skipping workspace initialization."
  exit 0
fi

should_initialize=0
case "${TARGET_DIR}" in
  /workspaces/*) should_initialize=1 ;;
esac

if [ -d "${TARGET_DIR}/.git" ] || [ -d "${TARGET_DIR}/.devcontainer" ] || [ -f "${TARGET_DIR}/devcontainer.json" ]; then
  should_initialize=1
fi

if [ "${should_initialize}" -ne 1 ]; then
  log "Skipping workspace initialization outside a detected workspace root: ${TARGET_DIR}"
  exit 0
fi

if [ ! -w "${TARGET_DIR}" ]; then
  fail "Workspace path '${TARGET_DIR}' is not writable."
fi

CACHE_BASE="${XDG_CACHE_HOME:-${HOME}/.cache}/openspec-devcontainer"
mkdir -p "${CACHE_BASE}"
CACHE_KEY="$(printf '%s|%s\n' "${TARGET_DIR}" "${TOOLS}" | sha256sum | awk '{print $1}')"
SENTINEL="${CACHE_BASE}/${CACHE_KEY}.initialized"

if [ -f "${SENTINEL}" ]; then
  exit 0
fi

log "Initializing OpenSpec tool support (${TOOLS}) in ${TARGET_DIR}"
openspec init --tools "${TOOLS}" "${TARGET_DIR}"
touch "${SENTINEL}"
EOF

  chmod +x /usr/local/bin/openspec-init-workspace
}

write_profile_hook() {
  cat > "${PROFILE_HOOK}" <<'EOF'
#!/bin/sh

if [ "${OPENSPEC_DEVCONTAINER_DISABLE_AUTO_INIT:-0}" = "1" ]; then
  return 0 2>/dev/null || exit 0
fi

if [ -t 1 ] && command -v openspec-init-workspace >/dev/null 2>&1; then
  openspec-init-workspace "$PWD" >/dev/null || echo "[openspec-feature] Workspace initialization failed for $PWD" >&2
fi
EOF

  chmod +x "${PROFILE_HOOK}"
}

main() {
  log "Activating feature 'openspec'"

  raw_tool_support="${TOOLSUPPORT:-${TOOL_SUPPORT:-none}}"
  normalized_tool_support="$(normalize_tool_support "${raw_tool_support}")"

  if node_is_usable; then
    log "Reusing existing Node.js runtime: $(node --version)"
  else
    install_node
  fi

  log "Installing OpenSpec CLI from npm package ${OPEN_SPEC_PACKAGE}"
  npm install -g "${OPEN_SPEC_PACKAGE}"

  command -v openspec >/dev/null 2>&1 || fail "OpenSpec CLI was not added to PATH."
  openspec --version >/dev/null 2>&1 || fail "OpenSpec CLI did not execute successfully after installation."

  mkdir -p "${CONFIG_DIR}"
  cat > "${CONFIG_FILE}" <<EOF
OPENSPEC_FEATURE_TOOL_SUPPORT='${normalized_tool_support}'
EOF

  write_tool_support_helper
  write_workspace_init_helper
  write_profile_hook

  if [ "${normalized_tool_support}" = "none" ]; then
    log "Configured with toolSupport=none. OpenSpec CLI installed without running openspec init."
  else
    log "Configured deferred workspace initialization for toolSupport=${normalized_tool_support}."
  fi
}

main "$@"
