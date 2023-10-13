#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'aws-sam-cli' Feature with no options.
#

#!/usr/bin/env bash

# This test file will be executed against one of the scenarios devcontainer.json test that
# includes the 'aws-sam-cli' feature with "version": "latest" option.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "execute command" bash -c "sam --version | grep 'SAM CLI, version'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
