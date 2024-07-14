#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Copyright (c) Austrian Institute of Technology. All rights reserved.
# Licensed under the MIT License. See https://github.com/AIT-Assistive-Autonomous-Systems/devcontainer_features/blob/main/LICENSE for license information.
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Maintainer: * @AIT-Assistive-Autonomous-Systems/maintainers
# This test file will be executed against the scenario add_groups_value.sh

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

ADD_GROUPS="100(group0),105(group1),65536(group2),1004(group3)"
CURRENT_GROUPS=$($SCRIPT_DIR/collect_user_groups.sh otheruser)
ORIGINAL_GROUPS=$(cat /test/add_groups_file_backup)

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "verify added groups" $SCRIPT_DIR/check_user_group.sh "$CURRENT_GROUPS" "$ADD_GROUPS"
check "verify original groups" $SCRIPT_DIR/check_user_group.sh "$CURRENT_GROUPS" "" "$ORIGINAL_GROUPS"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
