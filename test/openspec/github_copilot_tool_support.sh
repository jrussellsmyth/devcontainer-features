#!/bin/bash

set -e

source dev-container-features-test-lib

check "github-copilot toolSupport configured" bash -lc "[ \"$(openspec-feature-tool-support current)\" = 'github-copilot' ]"
check "github-copilot workspace init helper creates files" bash -lc "workspace=\$(mktemp -d) && mkdir -p \"\$workspace/.git\" && openspec-init-workspace \"\$workspace\" >/tmp/github-copilot-init.out && test -f \"\$workspace/.github/prompts/opsx-apply.prompt.md\" && test -f \"\$workspace/.github/skills/openspec-apply-change/SKILL.md\""

reportResults
