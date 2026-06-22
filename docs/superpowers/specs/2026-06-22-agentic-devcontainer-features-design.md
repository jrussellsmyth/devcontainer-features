# Design: Agentic Development Dev Container Features

This document outlines the architecture, components, and implementation plan for a set of Dev Container features to prepare development environments for agentic development.

---

## 1. Features Overview

We are introducing three distinct, modular features to provide agent harnesses, structured workflows, and cross-session state persistence.

| Feature ID | Name | Purpose |
|------------|------|---------|
| `antigravity-cli` | Antigravity CLI | Installs the Google Antigravity CLI (`agy` binary) globally. |
| `superpowers` | Superpowers Agentic Skills | Installs the `obra/superpowers` skills framework and registers hooks/skills. |
| `cli-persistent-config` | CLI Persistent Config | Shares configuration, tokens, and history via named volumes with dynamic symlinking. |

---

## 2. Component Design & Architectures

### 2.1. `antigravity-cli`
- **Source**: Fetches the official bootstrapper script from `https://antigravity.google/cli/install.sh`.
- **Target**: Executed with `-d /usr/local/bin` to ensure the `agy` binary is globally accessible.
- **Verification**: Asserts `agy` is available on the path and runs with zero issues.

### 2.2. `superpowers` (Global Stash + Startup Linking)
- **Build-Time Hook**:
  - Installs `git` if missing.
  - Clones `https://github.com/obra/superpowers` to a shared system directory `/usr/local/share/superpowers`.
  - Places a workspace/home helper script at `/usr/local/bin/superpowers-init-workspace`.
  - Installs a profile script `/etc/profile.d/superpowers-init-workspace.sh` to execute the helper on interactive shell startup.
- **Runtime Hook (`superpowers-init-workspace`)**:
  - Resolves `$HOME` of the active shell user.
  - Links the stashed repository to `~/.claude/plugins/superpowers` (if `claude` is detected or expected).
  - Dynamically links the stashed `skills/` and `commands/` folders into the active workspace directories:
    - **Antigravity (`agy`)**: `.gemini/skills/`, `.gemini/commands/`
    - **GitHub Copilot**: `.github/skills/`, `.github/prompts/`
    - **OpenCode**: `.opencode/skills/`, `.opencode/command/`

### 2.3. `cli-persistent-config` (Neutral Mounts + Dynamic Symlinks)
- **Mount Targets**: Configures Named Volumes mapping to system directories in the container:
  - `claude-code-config` -> `/var/lib/agent-configs/claude`
  - `gemini-config` -> `/var/lib/agent-configs/gemini`
  - `crush-config` -> `/var/lib/agent-configs/crush`
  - `copilot-config` -> `/var/lib/agent-configs/copilot`
  - `opencode-config` -> `/var/lib/agent-configs/opencode`
  - `codex-config` -> `/var/lib/agent-configs/codex`
  - `superpowers-config` -> `/var/lib/agent-configs/superpowers`
- **Build-Time Setup**:
  - Resolves `_CONTAINER_USER` (defaults to `node`).
  - Pre-creates `/var/lib/agent-configs/<tool>` directories.
  - `chown`s the target directories to the non-root container user so that mounted Docker volumes inherit these writable permissions automatically.
- **Runtime Hook (`/etc/profile.d/cli-persistent-config.sh`)**:
  - Resolves the current user's `$HOME`.
  - If config paths in `$HOME` (e.g. `~/.claude`) are not symlinks:
    - If a directory exists locally in `$HOME` and the target volume is empty, copies its content to `/var/lib/agent-configs/<tool>`.
    - Removes the local directory/file and creates a symbolic link pointing to the persistent system directory `/var/lib/agent-configs/<tool>`.

---

## 3. Testing Strategy

Standard test scripts will be placed under `test/` for each feature:
1. `test/antigravity-cli/test.sh`: Verifies `agy` command is executable.
2. `test/superpowers/test.sh`: Verifies superpowers is cloned to `/usr/local/share/superpowers` and creates links under home/workspace on shell startup.
3. `test/cli-persistent-config/test.sh`: Verifies symlinks are correctly created from the user's home directories to `/var/lib/agent-configs/`.
