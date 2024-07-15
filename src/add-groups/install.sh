#!/bin/sh
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Copyright (c) Austrian Institute of Technology. All rights reserved.
# Licensed under the MIT License. See https://github.com/AIT-Assistive-Autonomous-Systems/devcontainer_features/blob/main/LICENSE for license information.
#---------------------------------------------------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/AIT-Assistive-Autonomous-Systems/devcontainer_features/main/src/add-groups
# Maintainer: * @AIT-Assistive-Autonomous-Systems/maintainers
set -eu

echo "Activating feature 'add-group'"

ADD_GROUPS="${1:-${ADDGROUPS:-}}"
ADD_GROUPS_FILE="${ADD_GROUPS#file://}"
ADD_GROUPS_USER="${2:-${_REMOTE_USER}}"
ADD_GROUPS_PATH="${3:-/usr/local/share/AIT-Assistive-Autonomous-Systems/devcontainer_features}"
STORE_BACKUP="${STOREBACKUP:-}"

mkdir -p "$ADD_GROUPS_PATH"
rm -f "$ADD_GROUPS_PATH/add-groups" || true

echo "$ADD_GROUPS" > "$ADD_GROUPS_PATH/add-groups"
echo "$ADD_GROUPS_USER" > "$ADD_GROUPS_PATH/add-groups-user"
echo "$STORE_BACKUP" > "$ADD_GROUPS_PATH/store-backup"

cp add-groups.sh $ADD_GROUPS_PATH/add-groups.sh
chmod +x $ADD_GROUPS_PATH/add-groups.sh
