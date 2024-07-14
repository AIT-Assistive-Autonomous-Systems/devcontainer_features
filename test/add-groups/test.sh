#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Copyright (c) Austrian Institute of Technology. All rights reserved.
# Licensed under the MIT License. See https://github.com/AIT-Assistive-Autonomous-Systems/devcontainer_features/blob/main/LICENSE for license information.
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Maintainer: * @AIT-Assistive-Autonomous-Systems/maintainers
# This test file will be executed against an auto-generated devcontainer.json.
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]

# We havve to re-execute the installation to verify no chnages were made.
ADD_GROUPS=""
ORIGINAL_GROUPS=$($SCRIPT_DIR/collect_user_groups.sh $(id -un))
cat "$ORIGINAL_GROUPS" || true
check "re-execute" .devcontainer/add-groups/add-groups.sh
CURRENT_GROUPS=$($SCRIPT_DIR/collect_user_groups.sh $(id -un))
check "no group changes" test "$ORIGINAL_GROUPS" = "$CURRENT_GROUPS"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
