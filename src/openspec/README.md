
# OpenSpec (openspec)

Installs the OpenSpec CLI and can initialize supported AI tool integrations in your workspace.

## Example Usage

```json
"features": {
    "ghcr.io/jrussellsmyth/devcontainer-features/openspec:1": {
        "toolSupport": "github-copilot,cursor"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| toolSupport | Configure OpenSpec tool support in the workspace on first interactive shell. Use `none`, `all`, or a comma-separated list of supported IDs. | string | none |

## Behavior

- The feature always installs the OpenSpec CLI with `npm install -g @fission-ai/openspec@latest`.
- OpenSpec currently requires Node.js `>=20.19.0`. If a usable `node` and `npm` are already available, the feature reuses them. Otherwise it installs Node.js `22.x`.
- `toolSupport=none` installs only the CLI and does not run `openspec init`.
- `toolSupport=all` expands to all currently supported OpenSpec tool identifiers.
- Any other `toolSupport` value must be a comma-separated list of supported tool IDs. Unsupported values fail the feature installation with a clear error.

## Deferred workspace initialization

`openspec init` writes repo-local files, so this feature defers that step until a writable workspace is available.

When `toolSupport` is anything other than `none`, the feature installs:

- `openspec-init-workspace` to initialize the current workspace on demand
- a shell hook in `/etc/profile.d/openspec-init-workspace.sh` that runs on the first interactive login shell in a detected workspace
- `openspec-feature-tool-support` to inspect the normalized configured value

If you prefer to initialize manually, run:

```bash
openspec-init-workspace /workspaces/your-project
```

Set `OPENSPEC_DEVCONTAINER_DISABLE_AUTO_INIT=1` to disable the automatic shell hook and run the helper manually instead.

## Supported `toolSupport` values

Use `none`, `all`, or a comma-separated list drawn from:

`amazon-q`, `antigravity`, `auggie`, `claude`, `cline`, `codex`, `codebuddy`, `continue`, `costrict`, `crush`, `cursor`, `factory`, `gemini`, `github-copilot`, `iflow`, `kilocode`, `kiro`, `opencode`, `pi`, `qoder`, `qwen`, `roocode`, `trae`, `windsurf`

---

_Note: This file mirrors the generated README format used by devcontainer feature tooling. Any future documentation generation will derive from `devcontainer-feature.json` and may rewrite the option table wording._
