## Context

Devcontainers allow developers to define reproducible, consistent development environments. [Crush](https://github.com/charmbracelet/crush) is Charmbracelet's terminal-based AI coding assistant that integrates LLMs, LSP context, and MCP tools directly in the terminal. Currently, developers using devcontainers must manually install Crush; a first-class devcontainer feature removes this friction.

Crush is distributed via:
- Charm's apt repository (Debian/Ubuntu) — the target for this feature
- Homebrew, npm, pkg, winget, Scoop, Nix

This repo already installs Charm repository keys in the `yarn-apt-publickey` feature as a pattern for Charm tooling. Crush follows the same apt repository: `https://repo.charm.sh/apt/`.

## Goals / Non-Goals

**Goals:**
- Install the `crush` CLI in Debian/Ubuntu-based devcontainers via the Charm apt repository
- Support a `version` option to pin a specific release (default: `latest`)
- Follow existing feature conventions: `#!/bin/sh`, `set -eu`, `log()`/`fail()`, apt cache cleanup
- Provide a test script using `dev-container-features-test-lib`

**Non-Goals:**
- Configuring AI provider API keys (secrets management is out of scope)
- Installing Crush via Homebrew, npm, or other package managers
- Supporting non-Debian/Ubuntu base images in the initial version

## Decisions

### Decision: Use Charm apt repository
**Rationale**: The Charm apt repository is the canonical Linux distribution channel for Crush and is already used by the `yarn-apt-publickey` feature pattern. It provides signed packages and version pinning support.  
**Alternative considered**: `go install github.com/charmbracelet/crush@latest` — simpler but requires Go runtime and doesn't support version pinning cleanly.

### Decision: Version option with `latest` default
**Rationale**: Pinning a version enables reproducible builds. `latest` as the default minimizes friction for most users while allowing teams to stabilize on a known-good version.  
**Implementation**: When `version=latest`, install `crush` via `apt-get install -y crush`. When a version is specified, install `crush=<version>` and use `apt-get install -y crush=<version>`.

### Decision: No automatic API key configuration
**Rationale**: API keys are secrets that should not be embedded in devcontainer feature configuration. Users should set them as environment variables (e.g., `ANTHROPIC_API_KEY`) via their secrets management tooling.

## Risks / Trade-offs

- [Risk] Charm apt repository changes or goes down → Mitigation: fail with a clear error message; no silent fallback
- [Risk] Version string format changes between Crush releases → Mitigation: test with `latest` in CI; document version format in README
- [Risk] Feature only supports Debian/Ubuntu → Mitigation: document supported base images clearly; print a helpful error on unsupported distros

## Migration Plan

No migration needed — this is a new feature with no existing users.
