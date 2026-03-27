## Why

This repository currently provides a narrow set of devcontainer features, but it does not include a feature for installing and configuring OpenSpec itself. Adding one here makes OpenSpec setup reproducible in devcontainers and lets consumers opt into the specific OpenSpec tool support they need instead of hand-rolling installation steps in each project.

## What Changes

- Add a new devcontainer feature under `src/` that installs the OpenSpec CLI in a containerized development environment.
- Expose a `toolSupport` feature option that defaults to `none` and lets consumers choose which OpenSpec tool support packages or integrations are installed alongside the core OpenSpec setup.
- Configure the feature so the OpenSpec CLI is available after container creation, and only run `openspec init` when tool support other than `none` is requested.
- Declare that the feature installs after the Node devcontainer feature when that feature is present, and bootstrap Node itself when it is not already available in the container.
- Add documentation and tests for the new feature following the repository's existing feature layout.

## Capabilities

### New Capabilities
- `openspec-devcontainer-feature`: Provide a reusable devcontainer feature that installs and configures OpenSpec with selectable tool support.

### Modified Capabilities

## Impact

- Adds a new feature directory in `src/` with `devcontainer-feature.json`, `install.sh`, and generated documentation.
- Adds corresponding coverage in `test/` for feature installation and option handling.
- Updates top-level documentation to list the new feature and its purpose.
- Introduces installation logic for Node availability, the OpenSpec CLI, conditional `openspec init` behavior, and selected tool support within the container environment.
