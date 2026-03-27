## 1. Feature scaffolding

- [x] 1.1 Create `src/openspec/` with `devcontainer-feature.json`, `install.sh`, and generated `README.md` content following the `devcontainers/feature-starter` layout used by this repository.
- [x] 1.2 Create `test/openspec/test.sh` and any required scenario files so the feature can be exercised by the standard devcontainer feature test harness.

## 2. Metadata and documentation

- [x] 2.1 Define OpenSpec feature metadata in `src/openspec/devcontainer-feature.json`, including name, id, description, version, `installsAfter`, and the `toolSupport` option with documented supported values.
- [x] 2.2 Generate or update `src/openspec/README.md` so it includes example usage, the options table, default behavior, Node coordination behavior, and supported `toolSupport` values.
- [x] 2.3 Update the repository `README.md` so the OpenSpec feature appears in the published feature list with a short description.

## 3. Installation behavior

- [x] 3.1 Implement `src/openspec/install.sh` to detect or install Node, install the OpenSpec CLI, and verify the `openspec` command is available on `PATH`.
- [x] 3.2 Implement `toolSupport` handling for `none`, `all`, and comma-separated supported integration identifiers, running `openspec init` only when tool support other than `none` is requested.
- [x] 3.3 Fail installation with a clear error when `toolSupport` contains unsupported values.

## 4. Validation

- [x] 4.1 Add default-path coverage to `test/openspec/test.sh` to confirm OpenSpec installs successfully and `openspec init` is skipped when `toolSupport` is `none`.
- [x] 4.2 Add scenario-based coverage for non-default `toolSupport` values and for Node fallback versus Node reuse behavior where supported by the repository test approach.
- [x] 4.3 Run the repository's existing validation and test commands to confirm the new feature matches the repository's standard feature workflows.
