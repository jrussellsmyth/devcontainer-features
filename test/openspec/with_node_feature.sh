#!/bin/bash

set -e

source dev-container-features-test-lib

check "openspec command available with node feature" bash -lc "command -v openspec && openspec --version"
check "node runtime available with node feature" bash -lc "command -v node && command -v npm"
check "default toolSupport remains none with node feature" bash -lc "[ \"$(openspec-feature-tool-support current)\" = 'none' ]"

reportResults
