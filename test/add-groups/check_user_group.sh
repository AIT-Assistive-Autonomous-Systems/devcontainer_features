#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Copyright (c) Austrian Institute of Technology. All rights reserved.
# Licensed under the MIT License. See https://github.com/AIT-Assistive-Autonomous-Systems/devcontainer_features/blob/main/LICENSE for license information.
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Maintainer: * @AIT-Assistive-Autonomous-Systems/maintainers
# Will exit 0 if the user is still part of the original groups and the new required groups with specified ids.

CURRENT_GROUPS=${1:-}
ADD_GROUPS=${2:-}
ORIGINAL_GROUPS=${3:-}

#ORIGINAL_GROUPS=$(cat $ADD_GROUPS_PATH/store-backup/groups)
#CURRENT_GROUPS=$(id $ADD_GROUPS_USER | cut -d = -f 4 | sed -E "s/$(id -g)\($(id -gn)\),?//")

groups_in_groups() {
    local current_groups=$1
    local groups=$2
    local gid=${3:-}
    local regex

    groups=$(echo $groups | tr ',' ' ')

    for group in $groups; do
        group_name="$(echo $group | cut -d "(" -f 2 | cut -d ")" -f 1)"
        if [ -n "$gid" ]; then
            gid="$(echo $group | cut -d "(" -f 1)"
            regex="(^|,)$gid\($group_name\)($|,)"
        else
            regex="(^|,)[0-9]+\($group_name\)($|,)"
        fi
        if [[ $current_groups =~ $regex ]]; then
            true
        else
            return 1
        fi
    done
    return 0
}

set -eu

if [ -n "$ADD_GROUPS" ]; then
    groups_in_groups "$CURRENT_GROUPS" "$ADD_GROUPS" 0
fi
if [ -n "$ORIGINAL_GROUPS" ]; then
    groups_in_groups "$CURRENT_GROUPS" "$ORIGINAL_GROUPS"
fi
