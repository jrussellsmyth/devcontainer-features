#!/bin/bash

set -e

source dev-container-features-test-lib

check "openspec command available" bash -lc "command -v openspec"
check "openspec command executes" bash -lc "openspec --version"
check "node available" bash -lc "command -v node && command -v npm"
check "node version supported" bash -lc "node -e \"const [major, minor, patch] = process.versions.node.split('.').map(Number); process.exit(major > 20 || (major === 20 && (minor > 19 || (minor === 19 && patch >= 0))) ? 0 : 1)\""
check "toolSupport config readable" bash -lc "command -v openspec-feature-tool-support && openspec-feature-tool-support current >/tmp/openspec-tool-support-current"
check "default skips workspace init helper" bash -lc "if [ \"$(openspec-feature-tool-support current)\" = 'none' ]; then workspace=\$(mktemp -d) && openspec-init-workspace \"\$workspace\" >/tmp/openspec-init-default.out && test ! -e \"\$workspace/.github/prompts/opsx-apply.prompt.md\" && grep -q 'toolSupport=none' /tmp/openspec-init-default.out; else exit 0; fi"
check "non-default toolSupport initializes workspace" bash -lc "current=\$(openspec-feature-tool-support current); if [ \"\$current\" != 'none' ]; then workspace=\$(mktemp -d) && mkdir -p \"\$workspace/.git\" && openspec-init-workspace \"\$workspace\" >/tmp/openspec-init-tools.out && test -f \"\$workspace/.github/prompts/opsx-apply.prompt.md\" && test -f \"\$workspace/.github/skills/openspec-apply-change/SKILL.md\"; else exit 0; fi"
check "invalid toolSupport values rejected" bash -lc "! openspec-feature-tool-support normalize invalid-tool >/tmp/openspec-invalid.out 2>/tmp/openspec-invalid.err && grep -q 'Unsupported toolSupport value' /tmp/openspec-invalid.err"

reportResults
