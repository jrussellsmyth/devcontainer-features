## Why

Developers using devcontainers want access to [Crush](https://github.com/charmbracelet/crush), Charmbracelet's terminal-based AI coding assistant, without having to manually install it. Providing a devcontainer feature makes it easy to add Crush to any devcontainer configuration.

## What Changes

- New devcontainer feature `crush` that installs the Crush CLI in the container
- Crush will be installed from the Charm apt repository on Debian/Ubuntu systems
- Option to specify the version to install (default: latest)

## Capabilities

### New Capabilities
- `crush-feature`: A devcontainer feature that installs the Crush CLI (`crush`) from Charmbracelet's apt repository, enabling terminal-based AI coding assistance inside devcontainers

### Modified Capabilities
<!-- No existing capabilities are changing -->

## Impact

- New files: `src/crush/devcontainer-feature.json`, `src/crush/install.sh`, `src/crush/README.md`
- New test files: `test/crush/test.sh`
- No breaking changes to existing features
- Adds a dependency on Charm's apt repository for Debian/Ubuntu-based containers
