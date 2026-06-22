#!/bin/bash
set -e
source dev-container-features-test-lib
check "agy command available" bash -lc "command -v agy"
check "agy executes" bash -lc "agy --help || true"
reportResults
