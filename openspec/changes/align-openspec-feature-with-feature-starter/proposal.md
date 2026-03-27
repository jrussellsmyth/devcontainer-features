## Why

This repository already has a proposed OpenSpec devcontainer feature, but the current plan does not explicitly anchor that work to the repository structure, metadata shape, generated documentation flow, and test conventions used by the preferred `devcontainers/feature-starter` template. Tightening the proposal now reduces implementation drift and makes the resulting feature easier to publish, validate, and maintain alongside the repository's existing features.

## What Changes

- Define the OpenSpec feature around the `feature-starter` repository conventions: `src/<feature>/` layout, `devcontainer-feature.json`, `install.sh`, generated feature README, and matching `test/<feature>/test.sh`.
- Require the OpenSpec feature metadata, documentation, and tests to follow the same patterns this repository already uses for published features and that `feature-starter` demonstrates.
- Specify how the OpenSpec feature should express options, `installsAfter`, documentation examples, and validation coverage so the implementation fits naturally into the existing release and test workflows.
- Capture the repository-level documentation and wiring updates needed so the new feature appears as a first-class member of this feature collection.

## Capabilities

### New Capabilities
- `openspec-devcontainer-feature`: Provide an OpenSpec devcontainer feature whose structure, metadata, documentation, and validation align with the preferred `devcontainers/feature-starter` conventions.

### Modified Capabilities

## Impact

- Affects the planned `src/openspec/` feature directory, including `devcontainer-feature.json`, `install.sh`, and generated `README.md`.
- Affects `test/openspec/` coverage and any shared test scenarios needed to exercise the feature in the same style as `feature-starter`.
- Affects the top-level `README.md` and the proposal/design/tasks artifacts for the OpenSpec feature work.
- Constrains implementation to remain compatible with the repository's existing GitHub Actions validation and release workflow layout.
