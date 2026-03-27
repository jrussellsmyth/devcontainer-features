## Context

This repository already follows the standard devcontainer feature collection layout with feature content in `src/<feature-id>/`, matching smoke tests in `test/<feature-id>/`, and the expected release, validate, and test workflows under `.github/workflows/`. The planned OpenSpec feature needs to fit that layout while also adopting the conventions demonstrated by `devcontainers/feature-starter`: feature metadata in `devcontainer-feature.json`, a single `install.sh` entrypoint, generated feature README content, example-based documentation, and test scripts that work with the devcontainer feature test harness.

The earlier OpenSpec feature proposal established the behavioral goals for installing OpenSpec, handling Node availability, and supporting optional tool integrations. This alignment change preserves those goals but makes the template-level expectations explicit so implementation decisions do not drift from the preferred feature collection shape.

## Goals / Non-Goals

**Goals:**
- Add the OpenSpec feature in a way that mirrors `feature-starter` structure and documentation conventions.
- Preserve the previously proposed OpenSpec behavior: install the CLI, handle Node prerequisites, and support configurable tool support.
- Ensure the feature metadata, generated README content, repository README entry, and tests are all shaped for the repository's existing validation and publishing workflows.
- Keep the feature self-contained so consumers can use it with or without separately including the Node devcontainer feature.

**Non-Goals:**
- Rework the repository's GitHub Actions workflows beyond the wiring needed for the new feature to participate in them.
- Introduce a custom repository structure that diverges from `feature-starter` conventions.
- Expand the first version of the feature to every possible OpenSpec integration; a curated, documented set is sufficient.

## Decisions

### Use the standard feature collection layout end-to-end

The feature will live in `src/openspec/` with `devcontainer-feature.json`, `install.sh`, and generated README content, and it will be paired with `test/openspec/test.sh` plus scenario files only if option coverage needs them. This matches both the existing repository layout and the `feature-starter` shape, which keeps release and test automation predictable.

Alternative considered: introducing extra helper directories or a custom docs structure. Rejected because it would make the feature harder to compare with `feature-starter` and add repository-specific complexity without clear benefit.

### Express user-facing behavior primarily through feature metadata

The feature's configuration surface will be defined in `devcontainer-feature.json`, including `toolSupport`, defaults, descriptions, and `installsAfter` metadata for the Node feature. The generated README should derive its options table and example usage from that metadata so the docs stay synchronized with the actual feature contract.

Alternative considered: documenting behavior mainly in handwritten README prose. Rejected because the repository already benefits from generated feature docs, and `feature-starter` treats metadata as the source of truth for options and examples.

### Keep installation in a single `install.sh` entrypoint

The install script will follow the standard feature entrypoint model: validate prerequisites, ensure Node is available, install the OpenSpec CLI, and branch on `toolSupport` for optional initialization and tool support installation. Keeping the logic in one script aligns with `feature-starter`, fits the size of the feature, and makes test behavior easy to trace.

Alternative considered: splitting installation and configuration into multiple helper scripts. Rejected for now because it would add indirection without addressing a demonstrated complexity problem.

### Align testing with the devcontainer feature harness patterns

Default behavior will be verified in `test/openspec/test.sh` using the same test-library style shown in `feature-starter`, and additional scenarios will be added only when needed to exercise non-default `toolSupport` values or Node fallback behavior. This keeps tests compatible with the repository's current test workflow while still covering the feature's higher-risk branches.

Alternative considered: relying only on ad hoc shell checks or only validating the default path. Rejected because configurable tool support and runtime detection are core feature behavior and should be exercised through the standard harness.

## Risks / Trade-offs

- [OpenSpec installation steps may evolve upstream] → Mitigation: keep the install flow centralized in `install.sh`, validate the installed CLI, and document supported installation behavior in metadata and tests.
- [Generated README content can drift from intended examples if metadata is incomplete] → Mitigation: treat `devcontainer-feature.json` as the canonical contract and ensure examples and option descriptions are explicit there.
- [Optional tool support may require extra system dependencies in some images] → Mitigation: keep the supported integration set curated, validate values strictly, and cover supported combinations in tests.
- [Adding alignment requirements could duplicate earlier OpenSpec proposal content] → Mitigation: make this change self-contained and implementation-ready so it can stand on its own as the authoritative plan for the feature.
