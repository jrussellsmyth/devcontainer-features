
# OpenSpec (openspec)

Installs the OpenSpec CLI and can initialize supported AI tool integrations in your workspace.

## Example Usage

```json
"features": {
    "ghcr.io/jrussellsmyth/devcontainer-features/openspec:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| toolSupport | Configure OpenSpec tool support in the workspace on first interactive shell. Use 'none', 'all', or a comma-separated list of supported IDs: amazon-q, antigravity, auggie, claude, cline, codex, codebuddy, continue, costrict, crush, cursor, factory, gemini, github-copilot, iflow, kilocode, kiro, opencode, pi, qoder, qwen, roocode, trae, windsurf. | string | none |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jrussellsmyth/devcontainer-features/blob/main/src/openspec/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
