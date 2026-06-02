# Crush

Installs [Crush](https://github.com/charmbracelet/crush), Charmbracelet's terminal-based AI coding assistant, from the Charm apt repository.

## Usage

Add to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/jrussellsmyth/devcontainer-features/crush:1": {}
  }
}
```

## Options

### version

Specifies the version of Crush to install. Default is `latest`, which installs the most recent available version.

To pin a specific version:

```json
{
  "features": {
    "ghcr.io/jrussellsmyth/devcontainer-features/crush:1": {
      "version": "0.1.0"
    }
  }
}
```

## Supported Base Images

- Debian/Ubuntu-based images (e.g., `mcr.microsoft.com/devcontainers/base:debian`, `mcr.microsoft.com/devcontainers/base:ubuntu`)

## Notes

- Crush requires API keys for LLM providers (e.g., OpenAI, Anthropic). Set these as environment variables in your devcontainer configuration or shell profile.
- The feature installs Crush from the official Charm apt repository.
