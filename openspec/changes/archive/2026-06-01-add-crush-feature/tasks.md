## 1. Feature Scaffold

- [x] 1.1 Create `src/crush/` directory
- [x] 1.2 Create `src/crush/devcontainer-feature.json` with id, name, version, description, and `version` option
- [x] 1.3 Create `src/crush/README.md` with usage examples and supported options

## 2. Install Script

- [x] 2.1 Create `src/crush/install.sh` with `#!/bin/sh` and `set -eu`
- [x] 2.2 Add `log()` and `fail()` helper functions with `[crush]` prefix
- [x] 2.3 Add `apt_install()` helper that runs `apt-get update` then `apt-get install -y --no-install-recommends`
- [x] 2.4 Add Charm GPG key setup: create `/etc/apt/keyrings/charm.gpg` from `https://repo.charm.sh/apt/gpg.key`
- [x] 2.5 Add Charm apt source list entry to `/etc/apt/sources.list.d/charm.list`
- [x] 2.6 Install `crush` (or `crush=<version>` when version is specified) via apt
- [x] 2.7 Verify `crush` is on PATH after installation; fail with clear error if not
- [x] 2.8 Clean up apt cache with `rm -rf /var/lib/apt/lists/*`

## 3. Tests

- [x] 3.1 Create `test/crush/` directory
- [x] 3.2 Create `test/crush/test.sh` sourcing `dev-container-features-test-lib`
- [x] 3.3 Add test: `crush` is available on PATH (`command -v crush`)
- [x] 3.4 Add test: `crush --version` exits 0 and prints a version string
- [x] 3.5 Call `reportResults` at end of test script
