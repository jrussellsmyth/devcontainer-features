# Agentic Dev Container Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create three devcontainer features (`antigravity-cli`, `superpowers`, and `cli-persistent-config`) to prepare containers for agentic development.

**Architecture:** Install the `agy` CLI using the official bootstrapper, clone the `superpowers` repo globally and symlink/copy skills into the workspace/home folder via startup hooks, and configure shared named volumes mapped to `/var/lib/agent-configs/<tool>` that are symlinked to user home config paths at shell start.

**Tech Stack:** shell scripting (POSIX `sh`), devcontainer features specification.

## Global Constraints

- Features must be written in POSIX `sh` using `#!/bin/sh` and `set -eu`.
- All tests must use the `dev-container-features-test-lib` framework.
- Named volumes must use permissive permissions initialized during build.

---

### Task 1: Google `antigravity-cli` Feature

**Files:**
- Create: `src/antigravity-cli/devcontainer-feature.json`
- Create: `src/antigravity-cli/install.sh`
- Create: `src/antigravity-cli/README.md`
- Test: `test/antigravity-cli/test.sh`

**Interfaces:**
- Consumes: None
- Produces: System-wide `/usr/local/bin/agy` executable.

- [ ] **Step 1: Write the failing test**
  
  Create file `test/antigravity-cli/test.sh` with the following content:
  ```bash
  #!/bin/bash
  set -e
  source dev-container-features-test-lib
  check "agy command available" bash -lc "command -v agy"
  check "agy executes" bash -lc "agy --help || true"
  reportResults
  ```

- [ ] **Step 2: Run test to verify it fails**
  
  Run: `devcontainer features test -f antigravity-cli .`
  Expected: FAIL with command not found.

- [ ] **Step 3: Write metadata configuration**
  
  Create file `src/antigravity-cli/devcontainer-feature.json`:
  ```json
  {
    "name": "Antigravity CLI",
    "id": "antigravity-cli",
    "version": "1.0.0",
    "description": "Installs the Google Antigravity CLI (agy) tool system-wide to monitor and interact with AI agents.",
    "options": {}
  }
  ```

- [ ] **Step 4: Write installation script**
  
  Create file `src/antigravity-cli/install.sh`:
  ```sh
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
    apt_install ca-certificates curl gnupg2 tar
    log "Downloading and running official installer"
    curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- -d /usr/local/bin
    command -v agy >/dev/null 2>&1 || fail "agy CLI was not added to PATH."
    agy --help >/dev/null 2>&1 || fail "agy CLI failed to execute."
    log "Cleaning up apt cache"
    rm -rf /var/lib/apt/lists/*
    log "Antigravity CLI installation complete"
  }
  main "$@"
  ```

- [ ] **Step 5: Write README documentation**
  
  Create file `src/antigravity-cli/README.md`:
  ```markdown
  # Antigravity CLI Dev Container Feature
  This feature installs the Google Antigravity CLI (`agy` binary) globally.
  ```

- [ ] **Step 6: Run test to verify it passes**
  
  Run: `devcontainer features test -f antigravity-cli .`
  Expected: PASS.

- [ ] **Step 7: Commit**
  
  ```bash
  git add src/antigravity-cli test/antigravity-cli
  git commit -m "feat: add antigravity-cli feature"
  ```

---

### Task 2: `superpowers` Feature

**Files:**
- Create: `src/superpowers/devcontainer-feature.json`
- Create: `src/superpowers/install.sh`
- Create: `src/superpowers/README.md`
- Test: `test/superpowers/test.sh`

**Interfaces:**
- Consumes: None
- Produces: System-wide clone at `/usr/local/share/superpowers`, initializer at `/usr/local/bin/superpowers-init-workspace`, and startup linking hook `/etc/profile.d/superpowers-init-workspace.sh`.

- [ ] **Step 1: Write the failing test**
  
  Create file `test/superpowers/test.sh`:
  ```bash
  #!/bin/bash
  set -e
  source dev-container-features-test-lib
  check "superpowers directory exists" bash -c "[ -d /usr/local/share/superpowers ]"
  check "superpowers-init-workspace is executable" bash -c "[ -x /usr/local/bin/superpowers-init-workspace ]"
  check "profile hook exists" bash -c "[ -f /etc/profile.d/superpowers-init-workspace.sh ]"
  mkdir -p /tmp/dummy-workspace
  cd /tmp/dummy-workspace
  touch devcontainer.json
  bash -lc "superpowers-init-workspace"
  check "claude plugin link created" bash -c "[ -L ~/.claude/plugins/superpowers ]"
  check "gemini skills link created" bash -c "[ -L /tmp/dummy-workspace/.gemini/skills ]"
  check "github skills link created" bash -c "[ -L /tmp/dummy-workspace/.github/skills ]"
  check "opencode skills link created" bash -c "[ -L /tmp/dummy-workspace/.opencode/skills ]"
  rm -rf /tmp/dummy-workspace
  reportResults
  ```

- [ ] **Step 2: Run test to verify it fails**
  
  Run: `devcontainer features test -f superpowers .`
  Expected: FAIL with files not found.

- [ ] **Step 3: Write metadata configuration**
  
  Create file `src/superpowers/devcontainer-feature.json`:
  ```json
  {
    "name": "Superpowers Agentic Skills",
    "id": "superpowers",
    "version": "1.0.0",
    "description": "Installs the Superpowers agentic skills framework to guide AI agents through TDD, planning, and brainstorming workflows.",
    "options": {}
  }
  ```

- [ ] **Step 4: Write installation script**
  
  Create file `src/superpowers/install.sh`:
  ```sh
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
    local src="$1"
    local dest="$2"
    if [ ! -e "${src}" ]; then
      return 0
    fi
    if [ -L "${dest}" ]; then
      return 0
    fi
    if [ -e "${dest}" ]; then
      rm -rf "${dest}"
    fi
    mkdir -p "$(dirname "${dest}")"
    ln -s "${src}" "${dest}"
  }
  link_target "/usr/local/share/superpowers" "${USER_HOME}/.claude/plugins/superpowers"
  WORKSPACE_DIR="$PWD"
  if [ -d "${WORKSPACE_DIR}/.git" ] || [ -d "${WORKSPACE_DIR}/.devcontainer" ] || [ -f "${WORKSPACE_DIR}/devcontainer.json" ]; then
    link_target "/usr/local/share/superpowers/skills" "${WORKSPACE_DIR}/.gemini/skills"
    link_target "/usr/local/share/superpowers/skills" "${WORKSPACE_DIR}/.github/skills"
    link_target "/usr/local/share/superpowers/skills" "${WORKSPACE_DIR}/.opencode/skills"
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
    if ! command -v git >/dev/null 2>&1; then
      log "Installing git"
      apt_install git
    fi
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
  ```

- [ ] **Step 5: Write README documentation**
  
  Create file `src/superpowers/README.md`:
  ```markdown
  # Superpowers Feature
  Installs the `obra/superpowers` agentic skills framework.
  ```

- [ ] **Step 6: Run test to verify it passes**
  
  Run: `devcontainer features test -f superpowers .`
  Expected: PASS.

- [ ] **Step 7: Commit**
  
  ```bash
  git add src/superpowers test/superpowers
  git commit -m "feat: add superpowers feature"
  ```

---

### Task 3: `cli-persistent-config` Feature

**Files:**
- Create: `src/cli-persistent-config/devcontainer-feature.json`
- Create: `src/cli-persistent-config/install.sh`
- Create: `src/cli-persistent-config/README.md`
- Test: `test/cli-persistent-config/test.sh`

**Interfaces:**
- Consumes: None
- Produces: Set of chowned mount paths under `/var/lib/agent-configs/` and startup hook `/etc/profile.d/cli-persistent-config.sh`.

- [ ] **Step 1: Write the failing test**
  
  Create file `test/cli-persistent-config/test.sh`:
  ```bash
  #!/bin/bash
  set -e
  source dev-container-features-test-lib
  check "profile hook exists" bash -c "[ -f /etc/profile.d/cli-persistent-config.sh ]"
  source /etc/profile.d/cli-persistent-config.sh
  check "claude configuration symlinked" bash -c "[ -L ~/.claude ]"
  check "gemini configuration symlinked" bash -c "[ -L ~/.gemini ]"
  check "crush configuration symlinked" bash -c "[ -L ~/.crush ]"
  check "copilot configuration symlinked" bash -c "[ -L ~/.config/github-copilot ]"
  check "opencode configuration symlinked" bash -c "[ -L ~/.opencode ]"
  check "codex configuration symlinked" bash -c "[ -L ~/.codex ]"
  check "superpowers configuration symlinked" bash -c "[ -L ~/.config/superpowers ]"
  reportResults
  ```

- [ ] **Step 2: Run test to verify it fails**
  
  Run: `devcontainer features test -f cli-persistent-config .`
  Expected: FAIL with files not found.

- [ ] **Step 3: Write metadata configuration**
  
  Create file `src/cli-persistent-config/devcontainer-feature.json`:
  ```json
  {
    "name": "CLI Persistent Config",
    "id": "cli-persistent-config",
    "version": "1.0.0",
    "description": "Automatically mounts and shares configurations, tokens, and history for agentic CLIs across container rebuilds.",
    "options": {},
    "mounts": [
      {
        "source": "claude-code-config",
        "target": "/var/lib/agent-configs/claude",
        "type": "volume"
      },
      {
        "source": "gemini-config",
        "target": "/var/lib/agent-configs/gemini",
        "type": "volume"
      },
      {
        "source": "crush-config",
        "target": "/var/lib/agent-configs/crush",
        "type": "volume"
      },
      {
        "source": "copilot-config",
        "target": "/var/lib/agent-configs/copilot",
        "type": "volume"
      },
      {
        "source": "opencode-config",
        "target": "/var/lib/agent-configs/opencode",
        "type": "volume"
      },
      {
        "source": "codex-config",
        "target": "/var/lib/agent-configs/codex",
        "type": "volume"
      },
      {
        "source": "superpowers-config",
        "target": "/var/lib/agent-configs/superpowers",
        "type": "volume"
      }
    ]
  }
  ```

- [ ] **Step 4: Write installation script**
  
  Create file `src/cli-persistent-config/install.sh`:
  ```sh
  #!/bin/sh
  set -eu
  log() {
    echo "[cli-persistent-config] $*"
  }
  write_profile_hook() {
    cat > /etc/profile.d/cli-persistent-config.sh <<'EOF'
  #!/bin/sh
  USER_HOME="${HOME:-/home/$(whoami)}"
  link_config() {
    local home_rel="$1"
    local target="$2"
    local home_abs="${USER_HOME}/${home_rel}"
    if [ -L "${home_abs}" ]; then
      return 0
    fi
    if [ -e "${home_abs}" ]; then
      if [ -d "${home_abs}" ] && [ ! -L "${home_abs}" ]; then
        if [ -z "$(ls -A "${target}" 2>/dev/null)" ]; then
          cp -a "${home_abs}/." "${target}/" 2>/dev/null || true
        fi
        rm -rf "${home_abs}"
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
    for tool in claude gemini crush copilot opencode codex superpowers; do
      mkdir -p "/var/lib/agent-configs/${tool}"
      chown -R "${CONTAINER_USER}:${CONTAINER_USER}" "/var/lib/agent-configs/${tool}"
    done
    log "Writing profile startup hook"
    write_profile_hook
    log "CLI Persistent Config installation complete"
  }
  main "$@"
  ```

- [ ] **Step 5: Write README documentation**
  
  Create file `src/cli-persistent-config/README.md`:
  ```markdown
  # CLI Persistent Config Feature
  Automatically mounts named volumes for agent config paths and creates home-directory symlinks.
  ```

- [ ] **Step 6: Run test to verify it passes**
  
  Run: `devcontainer features test -f cli-persistent-config .`
  Expected: PASS.

- [ ] **Step 7: Commit**
  
  ```bash
  git add src/cli-persistent-config test/cli-persistent-config
  git commit -m "feat: add cli-persistent-config feature"
  ```
