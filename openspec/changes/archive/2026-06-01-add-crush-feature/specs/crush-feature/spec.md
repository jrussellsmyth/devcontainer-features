## ADDED Requirements

### Requirement: Crush CLI is installed
The feature SHALL install the `crush` CLI binary from the Charm apt repository into the container so that the `crush` command is available on PATH after installation.

#### Scenario: Default install makes crush available
- **WHEN** the feature is installed with default options on a Debian/Ubuntu base image
- **THEN** the `crush` command is available on PATH

#### Scenario: crush binary is executable
- **WHEN** the feature is installed
- **THEN** running `crush --version` exits with code 0 and prints a version string

### Requirement: Charm apt repository is configured
The feature SHALL add the Charm apt repository GPG key and source list entry to the container so that `crush` can be installed and updated via apt.

#### Scenario: Charm apt key and repo are present
- **WHEN** the feature is installed
- **THEN** the Charm GPG key exists at `/etc/apt/keyrings/charm.gpg`
- **THEN** the Charm source list entry exists in `/etc/apt/sources.list.d/charm.list`

### Requirement: Version option controls which version is installed
The feature SHALL accept a `version` option. When set to `latest` (the default), the most recent available version SHALL be installed. When set to a specific version string, that exact version SHALL be installed.

#### Scenario: Default version installs latest crush
- **WHEN** the feature is installed without specifying a version
- **THEN** the installed crush binary reports a non-empty version

#### Scenario: Specific version is installed when requested
- **WHEN** the feature is installed with a specific version value (e.g., `0.1.0`)
- **THEN** the installed crush binary reports that version

### Requirement: apt cache is cleaned up after installation
The feature SHALL remove apt package lists after installation to keep the image size minimal.

#### Scenario: apt lists are removed after install
- **WHEN** the feature is installed
- **THEN** `/var/lib/apt/lists/` is empty or contains only lock files
