#!/bin/bash
set -e
source dev-container-features-test-lib
check "superpowers directory exists" bash -lc "[ -d /usr/local/share/superpowers ]"
check "superpowers-init-workspace is executable" bash -lc "[ -x /usr/local/bin/superpowers-init-workspace ]"
check "profile hook exists" bash -lc "[ -f /etc/profile.d/superpowers-init-workspace.sh ]"

# Positive Scenario: Inside a Workspace
mkdir -p /tmp/dummy-workspace
cd /tmp/dummy-workspace
touch devcontainer.json
bash -lc "superpowers-init-workspace"
check "claude plugin link created" bash -lc "[ -L ~/.claude/plugins/superpowers ]"
check "gemini skills link created" bash -lc "[ -L /tmp/dummy-workspace/.gemini/skills ]"
check "github skills link created" bash -lc "[ -L /tmp/dummy-workspace/.github/skills ]"
check "opencode skills link created" bash -lc "[ -L /tmp/dummy-workspace/.opencode/skills ]"
rm -rf /tmp/dummy-workspace

# Negative Scenario: Outside a Workspace
mkdir -p /tmp/dummy-non-workspace
cd /tmp/dummy-non-workspace
# Clear any links from prior runs
rm -rf ~/.claude/plugins/superpowers
bash -lc "superpowers-init-workspace"
check "claude plugin link created (global negative)" bash -lc "[ -L ~/.claude/plugins/superpowers ]"
check "gemini skills link not created (local negative)" bash -lc "[ ! -L /tmp/dummy-non-workspace/.gemini/skills ]"
check "github skills link not created (local negative)" bash -lc "[ ! -L /tmp/dummy-non-workspace/.github/skills ]"
check "opencode skills link not created (local negative)" bash -lc "[ ! -L /tmp/dummy-non-workspace/.opencode/skills ]"
rm -rf /tmp/dummy-non-workspace

reportResults
