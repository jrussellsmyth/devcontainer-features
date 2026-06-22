#!/bin/bash
set -e
source dev-container-features-test-lib
check "superpowers directory exists" bash -lc "[ -d /usr/local/share/superpowers ]"
check "superpowers-init-workspace is executable" bash -lc "[ -x /usr/local/bin/superpowers-init-workspace ]"
check "profile hook exists" bash -lc "[ -f /etc/profile.d/superpowers-init-workspace.sh ]"

# Pre-create test directories to verify links are generated if folders exist in the repository
mkdir -p /usr/local/share/superpowers/commands
mkdir -p /usr/local/share/superpowers/prompts

# Positive Scenario: Inside a Workspace
mkdir -p /tmp/dummy-workspace
cd /tmp/dummy-workspace
touch devcontainer.json
bash -lc "superpowers-init-workspace"
check "claude plugin link created" bash -lc "[ -L ~/.claude/plugins/superpowers ]"
check "gemini skills link created" bash -lc "[ -L /tmp/dummy-workspace/.gemini/skills ]"
check "gemini commands link created" bash -lc "[ -L /tmp/dummy-workspace/.gemini/commands ]"
check "github skills link created" bash -lc "[ -L /tmp/dummy-workspace/.github/skills ]"
check "github prompts link created" bash -lc "[ -L /tmp/dummy-workspace/.github/prompts ]"
check "opencode skills link created" bash -lc "[ -L /tmp/dummy-workspace/.opencode/skills ]"
check "opencode command link created" bash -lc "[ -L /tmp/dummy-workspace/.opencode/command ]"

# Positive Scenario: Inside a Workspace Subdirectory
mkdir -p /tmp/dummy-workspace/src/sub
cd /tmp/dummy-workspace/src/sub
# Clear links from prior runs
rm -rf ~/.claude/plugins/superpowers
bash -lc "superpowers-init-workspace"
check "claude plugin link created from subdirectory" bash -lc "[ -L ~/.claude/plugins/superpowers ]"
check "gemini skills link created from subdirectory" bash -lc "[ -L /tmp/dummy-workspace/.gemini/skills ]"
rm -rf /tmp/dummy-workspace

# Negative Scenario: Outside a Workspace
mkdir -p /tmp/dummy-non-workspace
cd /tmp/dummy-non-workspace
# Clear any links from prior runs
rm -rf ~/.claude/plugins/superpowers
bash -lc "superpowers-init-workspace"
check "claude plugin link created (global negative)" bash -lc "[ -L ~/.claude/plugins/superpowers ]"
check "gemini skills link not created (local negative)" bash -lc "[ ! -L /tmp/dummy-non-workspace/.gemini/skills ]"
check "gemini commands link not created (local negative)" bash -lc "[ ! -L /tmp/dummy-non-workspace/.gemini/commands ]"
check "github skills link not created (local negative)" bash -lc "[ ! -L /tmp/dummy-non-workspace/.github/skills ]"
check "github prompts link not created (local negative)" bash -lc "[ ! -L /tmp/dummy-non-workspace/.github/prompts ]"
check "opencode skills link not created (local negative)" bash -lc "[ ! -L /tmp/dummy-non-workspace/.opencode/skills ]"
check "opencode command link not created (local negative)" bash -lc "[ ! -L /tmp/dummy-non-workspace/.opencode/command ]"
rm -rf /tmp/dummy-non-workspace

reportResults
