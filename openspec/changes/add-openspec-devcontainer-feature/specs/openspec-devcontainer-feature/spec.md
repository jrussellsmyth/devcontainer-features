## ADDED Requirements

### Requirement: Feature installs OpenSpec CLI
The repository SHALL provide an `openspec` devcontainer feature that installs the OpenSpec CLI and makes it available in the container environment after feature installation completes.

#### Scenario: Default installation succeeds
- **WHEN** a devcontainer includes the `openspec` feature with default options
- **THEN** the OpenSpec CLI SHALL be installed successfully
- **AND** the `openspec` command SHALL be available on the container `PATH`
- **AND** `toolSupport` SHALL default to `none`
- **AND** the feature SHALL NOT run `openspec init`

### Requirement: Feature coordinates with Node availability
The `openspec` devcontainer feature SHALL prefer an existing Node devcontainer feature when it is present and SHALL install Node itself when the container does not already provide a usable Node runtime.

#### Scenario: Node feature is included
- **WHEN** a consumer includes both the Node devcontainer feature and the `openspec` feature
- **THEN** the `openspec` feature metadata SHALL declare the Node feature in `installsAfter`
- **AND** the `openspec` installation SHALL run after the Node feature

#### Scenario: Node runtime is absent
- **WHEN** a consumer includes the `openspec` feature in a container that does not already provide `node` and `npm`
- **THEN** the feature SHALL install a usable Node runtime before installing OpenSpec

#### Scenario: Node runtime is already available without the Node feature
- **WHEN** a consumer includes the `openspec` feature in a container where `node` and `npm` are already available
- **THEN** the feature SHALL reuse the existing Node runtime
- **AND** the feature SHALL NOT reinstall Node unnecessarily

### Requirement: Feature supports selectable tool support
The `openspec` devcontainer feature SHALL allow consumers to specify which supported OpenSpec tool integrations are installed through a feature option.

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
- **THEN** the feature SHALL install only the integrations named in that list
- **AND** the feature SHALL leave unspecified integrations uninstalled

### Requirement: Feature validates tool support input
The feature SHALL reject unsupported `toolSupport` values with a clear installation failure instead of silently ignoring invalid input.

#### Scenario: Unsupported integration identifier provided
- **WHEN** a consumer configures `toolSupport` with an identifier not documented by the feature
- **THEN** feature installation SHALL fail
- **AND** the failure output SHALL identify the unsupported value

### Requirement: Feature documents supported configuration
The repository SHALL document the OpenSpec feature's installation behavior, supported tool support values, and example usage in the feature README and metadata.

#### Scenario: Consumer reviews feature documentation
- **WHEN** a consumer reads `src/openspec/README.md` or the generated documentation derived from feature metadata
- **THEN** they SHALL be able to identify the default behavior
- **AND** they SHALL see that `toolSupport` defaults to `none`
- **AND** they SHALL see that `openspec init` only runs when tool support other than `none` is selected
- **AND** they SHALL see how the feature behaves when the Node feature is present or absent
- **AND** they SHALL see the supported `toolSupport` values and example configuration
