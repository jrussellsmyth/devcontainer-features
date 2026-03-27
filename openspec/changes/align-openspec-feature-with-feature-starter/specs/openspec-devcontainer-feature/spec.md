## ADDED Requirements

### Requirement: OpenSpec feature follows feature collection layout
The repository SHALL provide the OpenSpec feature using the same collection structure demonstrated by `devcontainers/feature-starter` and already used by this repository, with feature assets grouped under `src/<feature-id>/` and matching validation assets under `test/<feature-id>/`.

#### Scenario: Feature files are present in standard locations
- **WHEN** a maintainer inspects the OpenSpec feature in the repository
- **THEN** they SHALL find `src/openspec/devcontainer-feature.json`
- **AND** they SHALL find `src/openspec/install.sh`
- **AND** they SHALL find generated feature documentation at `src/openspec/README.md`
- **AND** they SHALL find feature validation at `test/openspec/test.sh`

### Requirement: OpenSpec feature metadata and documentation match starter conventions
The OpenSpec feature SHALL describe its public contract through `devcontainer-feature.json` and generated README content in a way that matches the conventions used by `devcontainers/feature-starter`, including example usage, option documentation, and install ordering metadata.

#### Scenario: Consumer reviews feature metadata
- **WHEN** a consumer reads `src/openspec/devcontainer-feature.json`
- **THEN** they SHALL see the feature name, id, version, and description
- **AND** they SHALL see the `toolSupport` option with a documented default of `none`
- **AND** they SHALL see `installsAfter` metadata that declares the Node devcontainer feature

#### Scenario: Consumer reviews generated feature documentation
- **WHEN** a consumer reads `src/openspec/README.md`
- **THEN** they SHALL see example `devcontainer.json` usage for the OpenSpec feature
- **AND** they SHALL see an options table derived from feature metadata
- **AND** they SHALL see documentation describing default behavior, supported `toolSupport` values, and Node coordination behavior

### Requirement: Feature installs OpenSpec CLI
The repository SHALL provide an `openspec` devcontainer feature that installs the OpenSpec CLI and makes the `openspec` command available on the container `PATH` after installation completes.

#### Scenario: Default installation succeeds
- **WHEN** a devcontainer includes the `openspec` feature with default options
- **THEN** the OpenSpec CLI SHALL be installed successfully
- **AND** the `openspec` command SHALL be available on the container `PATH`
- **AND** `toolSupport` SHALL default to `none`
- **AND** the feature SHALL NOT run `openspec init`

### Requirement: Feature coordinates with Node availability
The OpenSpec feature SHALL prefer an existing Node devcontainer feature when it is present and SHALL install Node itself when the container does not already provide a usable Node runtime.

#### Scenario: Node feature is included
- **WHEN** a consumer includes both the Node devcontainer feature and the `openspec` feature
- **THEN** the OpenSpec feature metadata SHALL declare the Node feature in `installsAfter`
- **AND** the OpenSpec installation SHALL run after the Node feature

#### Scenario: Node runtime is absent
- **WHEN** a consumer includes the `openspec` feature in a container that does not already provide `node` and `npm`
- **THEN** the feature SHALL install a usable Node runtime before installing OpenSpec

#### Scenario: Node runtime is already available without the Node feature
- **WHEN** a consumer includes the `openspec` feature in a container where `node` and `npm` are already available
- **THEN** the feature SHALL reuse the existing Node runtime
- **AND** the feature SHALL NOT reinstall Node unnecessarily

### Requirement: Feature supports selectable tool support
The OpenSpec feature SHALL allow consumers to specify which supported OpenSpec tool integrations are installed through the `toolSupport` feature option.

#### Scenario: No extra tool support requested
- **WHEN** the feature is configured with `toolSupport` set to `none` or left unspecified
- **THEN** the feature SHALL install the OpenSpec CLI without installing optional tool support integrations
- **AND** the feature SHALL NOT run `openspec init`

#### Scenario: All supported tool support requested
- **WHEN** the feature is configured with `toolSupport` set to `all`
- **THEN** the feature SHALL install every tool integration documented by the feature
- **AND** the feature SHALL run `openspec init` before applying tool support configuration

#### Scenario: Explicit tool support list requested
- **WHEN** the feature is configured with `toolSupport` set to a comma-separated list of supported integration identifiers
- **THEN** the feature SHALL run `openspec init`
- **AND** the feature SHALL install only the integrations named in that list
- **AND** the feature SHALL leave unspecified integrations uninstalled

### Requirement: Feature validates tool support input
The OpenSpec feature SHALL reject unsupported `toolSupport` values with a clear installation failure instead of silently ignoring invalid input.

#### Scenario: Unsupported integration identifier provided
- **WHEN** a consumer configures `toolSupport` with an identifier not documented by the feature
- **THEN** feature installation SHALL fail
- **AND** the failure output SHALL identify the unsupported value

### Requirement: Feature participates in repository documentation and validation flows
The repository SHALL wire the OpenSpec feature into the same documentation and validation surfaces used for other features in this collection.

#### Scenario: Maintainer reviews repository feature list
- **WHEN** a maintainer reads the top-level `README.md`
- **THEN** the OpenSpec feature SHALL appear in the published feature list with a short description

#### Scenario: Maintainer runs standard feature validation
- **WHEN** the repository's existing feature validation and test workflows run for the OpenSpec feature
- **THEN** they SHALL be able to execute the OpenSpec feature's standard test entrypoint and any declared scenarios without custom workflow logic
