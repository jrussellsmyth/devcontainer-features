## Context

This repository publishes devcontainer features as self-contained directories under `src/<feature-id>/` with matching smoke tests under `test/<feature-id>/`. The proposed OpenSpec feature needs to fit that layout, provide predictable installation behavior in Linux-based devcontainers, and expose an option for selecting which OpenSpec tool support is installed alongside the core CLI.

The archived Microsoft template remains useful as a structural reference: each feature needs a `devcontainer-feature.json`, an `install.sh`, generated feature documentation, and a test entrypoint. Unlike the existing `yarn-apt-publickey` feature, this change introduces a richer configuration surface and likely needs validation of option parsing as well as the resulting installed tooling.

## Goals / Non-Goals

**Goals:**
- Add a new feature directory for OpenSpec that matches the repository's established `src/` and `test/` structure.
- Ensure the feature cooperates with the existing Node devcontainer feature by installing after it when present.
- Install and configure the OpenSpec CLI so it is usable immediately after the feature runs.
- Ensure Node is available even in containers that do not include the Node devcontainer feature.
- Support a feature option for selecting tool support to install, with a deterministic mapping from option values to installed integrations.
- Document supported options and provide automated tests for the default and configurable paths.

**Non-Goals:**
- Rework the repository's publishing, release, or test infrastructure.
- Support non-Linux devcontainer environments.
- Implement every possible third-party editor or integration on day one; the feature can start with a curated set of supported tool integrations.

## Decisions

### Create a dedicated `openspec` feature directory

The implementation should add `src/openspec/` with `devcontainer-feature.json`, `install.sh`, and generated `README.md`, plus `test/openspec/test.sh`. This follows the repository's existing conventions and the structure expected by devcontainer feature tooling.

Alternative considered: folding OpenSpec installation into an existing feature. Rejected because it would make feature behavior less discoverable and would not match how this repository currently publishes independently consumable features.

### Declare Node as an installation predecessor and provide a fallback

The feature metadata should list the Node devcontainer feature in `installsAfter` so that, when both features are present, OpenSpec installation runs after Node has already provisioned the runtime. The install script should still detect whether `node` and `npm` are available and install Node itself when they are missing, so the OpenSpec feature remains usable as a standalone feature.

Alternative considered: requiring consumers to always include the Node feature explicitly. Rejected because it would make the OpenSpec feature less self-contained and create an avoidable setup failure for users who expect the feature to handle its own runtime prerequisites.

### Represent tool support as a single feature option with explicit parsing and a minimal default

The feature should expose a `toolSupport` option in `devcontainer-feature.json` and default it to `none`. The install script should accept a small, documented vocabulary:
- `none` for core OpenSpec only
- `all` for all supported integrations
- a comma-separated list for explicitly chosen integrations

This keeps the user-facing API compact while still allowing precise selection. Making `none` the default preserves a minimal install path and avoids running integration bootstrap steps unless a consumer explicitly opts in.

Alternative considered: separate boolean options per integration. Rejected because it scales poorly as supported integrations grow and makes feature configuration noisier in `devcontainer.json`.

### Keep installation logic self-contained in `install.sh`

The feature should perform installation and configuration in a single entrypoint script, sourcing feature-provided environment values and applying option parsing there. The script should install the OpenSpec CLI first, then branch on `toolSupport`: if the value is `none`, it should skip `openspec init`; otherwise, it should run `openspec init`, install the requested tool support, and finally verify the resulting commands or artifacts are available.
Before installing OpenSpec, the script should ensure a Node runtime is present, reusing the environment supplied by the Node feature when available and performing its own Node installation only when the runtime is absent.

Alternative considered: splitting logic across multiple helper scripts. Rejected for now because the feature is small enough to keep maintainable in one script and the repository currently uses simple, self-contained install scripts.

### Test both default and configurable behavior

The test should verify that the base OpenSpec installation succeeds and that selecting tool support changes the installed result in a detectable way. This ensures the feature contract remains stable as future updates are made.

Alternative considered: testing only the default installation path. Rejected because the main new behavior in this change is configurable tool support, and skipping it would leave the highest-risk path unverified.

## Risks / Trade-offs

- [OpenSpec distribution method changes] -> Mitigation: isolate install source selection in the feature script and validate the installed CLI before completing.
- [Tool support identifiers drift from upstream naming] -> Mitigation: document the supported values explicitly in `devcontainer-feature.json` and README, and keep test coverage aligned with those values.
- [Additional tool support increases install time] -> Mitigation: default `toolSupport` to `none`, skip `openspec init` for that path, and make expanded support opt-in.
- [Feature order differs across consuming devcontainers] -> Mitigation: declare `installsAfter` for the Node feature and keep an explicit runtime availability check in `install.sh`.
- [Some integrations may require extra runtime dependencies] -> Mitigation: keep the first version focused on integrations that can be installed reliably in common Debian-based devcontainers.
