## 1. Feature scaffolding

- [x] 1.1 Create `src/openspec/` with `devcontainer-feature.json`, `install.sh`, and generated README content following this repository's feature layout.
- [x] 1.2 Add feature metadata for the OpenSpec install flow, including `installsAfter` for the Node devcontainer feature, the `toolSupport` option with a default of `none`, and documented supported values.

## 2. Installation logic

- [x] 2.1 Implement `install.sh` to ensure Node is available, install the OpenSpec CLI, and verify the `openspec` command is available on `PATH`.
- [x] 2.2 Implement `toolSupport` parsing for `none`, `all`, and comma-separated supported integration identifiers, skipping `openspec init` when the effective value is `none`.
- [x] 2.3 Fail installation with a clear error when unsupported `toolSupport` values are provided.

## 3. Documentation and repository wiring

- [x] 3.1 Document the OpenSpec feature usage, Node dependency behavior, the default `toolSupport=none` behavior, conditional `openspec init`, and supported `toolSupport` values in `src/openspec/README.md`.
- [x] 3.2 Update the repository-level README so the new OpenSpec feature appears in the published feature list.

## 4. Validation

- [x] 4.1 Add `test/openspec/test.sh` to validate the default installation path, including that `openspec init` is not run when `toolSupport` is `none`.
- [x] 4.2 Add test coverage for Node fallback behavior, configurable tool support behavior, and invalid option handling where supported by the repository's test approach.
- [x] 4.3 Run the repository's existing validation commands and confirm the new feature behaves as documented.
