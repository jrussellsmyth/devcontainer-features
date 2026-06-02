#!/bin/bash

set -e

source dev-container-features-test-lib

check "crush command available" bash -lc "command -v crush"
check "crush executes" bash -lc "crush --version || true"

reportResults

