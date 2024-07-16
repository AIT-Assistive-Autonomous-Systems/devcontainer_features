#!/bin/sh
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Copyright (c) Austrian Institute of Technology. All rights reserved.
# Licensed under the MIT License. See https://github.com/AIT-Assistive-Autonomous-Systems/devcontainer_features/blob/main/LICENSE for license information.
#---------------------------------------------------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/AIT-Assistive-Autonomous-Systems/devcontainer_features/main/src/add-groups
# Maintainer: * @AIT-Assistive-Autonomous-Systems/maintainers

ADD_GROUPS_PATH="$(dirname $0)"
# We can not pass opts to vars or args of the commands it seems.
ADD_GROUPS="file://$ADD_GROUPS_PATH/add-groups"
ADD_GROUPS_USER="file://$ADD_GROUPS_PATH/add-groups-user"
EXCLUDE_GROUPS="file://$ADD_GROUPS_PATH/exclude-groups"
STORE_BACKUP="file://$ADD_GROUPS_PATH/store-backup"

print_usage() {
    echo "Usage: $0 -g groups_file -u user -b backup_path"

    echo "Add groups in file as suplemental groups to user and match ids."
    print_parsed_values
    exit 1
}

print_parsed_values() {
    echo values:
    echo "   -g \"$ADD_GROUPS\""
    echo "   -x \"$EXCLUDE_GROUPS\""
    echo "   -u \"$ADD_GROUPS_USER\""
    echo "   -b \"$STORE_BACKUP\""
}

load_content_if_exists() {
    # load value or content link
    # empty if content can not be loaded
    local content="$1"
    local content_file="${content#file://}"

    while [ "$content_file" != "$content" ]; do
        if [ -f "$content_file" ]; then
            content=$(cat "$content_file")
        else
            content=""
        fi
        content_file="${content#file://}"
    done

    echo $content
}

get_max_gid() {
    # Filter out another group, like the group you are trying to modify
    # or add and already exits.
    if [ -n "${2:-}" ]; then
        local max_gid="$(getent group | grep -v nogroup | grep -v $2 | cut -d: -f3 | \
            sort -nr | head -n 1)"
    else
        local max_gid="$(getent group | grep -v nogroup | cut -d: -f3 | sort -nr | head -n 1)"
    fi
    local nogroup_gid="$(getent group nogroup | cut -d: -f3)"
    local gid=${1:-0}
    max_gid=$((max_gid + 1))

    if [ "$gid" -ge "$max_gid" ]; then
        max_gid=$((gid + 1))
    fi
    if [ "$nogroup_gid" = "$max_gid" ]; then
        max_gid=$((max_gid + 1))
    fi
    echo $max_gid
}

exclude_groups() {
    # load value or content link
    # empty if content can not be loaded
    local groups="${1:-}"
    local exclude_groups="$(echo "${2:-}" | tr ',' ' ')"

    for group in $exclude_groups; do
        ### group is of the format id(groupname)
        groupname="$(echo $group | cut -d "(" -f 2 | cut -d ")" -f 1)"
        gid="$(echo $group | cut -d "(" -f 1)"

        if [ -z "$gid" ]; then
            gid="[0-9]+"
        fi

        if [ -z "$groupname" ]; then
            groupname="\w*"
        fi
        groups=`echo $groups | sed -E "s/$gid\($groupname\),?//"`
    done
    groups=`echo $groups | sed -E "s/,+$//"`

    echo "$groups"
}

set -eu

# Parse flag-based arguments
while getopts "hg:u:b:x:" opt; do
  case ${opt} in
    g)
      ADD_GROUPS=$OPTARG
      ;;
    x)
      EXCLUDE_GROUPS=$OPTARG
      ;;
    u)
      ADD_GROUPS_USER=$OPTARG
      ;;
    h)
      USAGE_REQ=1
      ;;
    b)
      STORE_BACKUP=$OPTARG
      ;;
    \?)
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    :)
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done

shift $((OPTIND -1))

if [ -n "${USAGE_REQ:-}" ]; then
    print_usage
fi

ADD_GROUPS=$(load_content_if_exists "$ADD_GROUPS")
EXCLUDE_GROUPS=$(load_content_if_exists "$EXCLUDE_GROUPS")
ADD_GROUPS_USER=$(load_content_if_exists "$ADD_GROUPS_USER")
STORE_BACKUP=$(load_content_if_exists "$STORE_BACKUP")

if [ "$ADD_GROUPS_USER" = "root" ]; then
    exit 0
fi

if [ "$(id -u)" != 0 ]; then
    SUDO_PREFIX=sudo
else
    SUDO_PREFIX=""
fi

if [ -n "$STORE_BACKUP" ]; then
    $SUDO_PREFIX mkdir -p $(dirname $STORE_BACKUP)
    id $ADD_GROUPS_USER | cut -d = -f 4 | \
        sed -E "s/$(id -g)\($(id -gn)\),?//" | $SUDO_PREFIX tee "$STORE_BACKUP"
fi

ADD_GROUPS=$(exclude_groups "$ADD_GROUPS" "$EXCLUDE_GROUPS" | tr ',' ' ')

### assign user the groups defined in ADD_GROUPS
for group in $ADD_GROUPS; do
    ### group is of the format id(groupname)
    echo "Checking group $group"
    groupname="$(echo $group | cut -d "(" -f 2 | cut -d ")" -f 1)"
    gid="$(echo $group | cut -d "(" -f 1)"

    # Compare provided gid with current max_gid and use the larger one
    max_gid=$(get_max_gid $gid)

    stored_groupname=$groupname
    if getent group $gid > /dev/null; then
        stored_groupname="$(getent group $gid | cut -d : -f 1)"
    fi

    if [ "$stored_groupname" != "$groupname" ] ; then
        echo "Moving group $max_gid($stored_groupname)"
        $SUDO_PREFIX groupmod -g $max_gid $stored_groupname
    fi

    ($SUDO_PREFIX groupmod -g $gid $groupname 2> /dev/null &&  echo "Set group $gid($groupname)") \
        || ($SUDO_PREFIX groupadd -g $gid $groupname && echo "Added group $gid($groupname)")
    $SUDO_PREFIX usermod -aG $gid $ADD_GROUPS_USER

    max_gid=$(get_max_gid 0 "$stored_groupname")

    if [ "$stored_groupname" != "$groupname" ] ; then
        echo "Moving group $max_gid($stored_groupname)"
        $SUDO_PREFIX groupmod -g $max_gid $stored_groupname
    fi
    # will not work but for completeness
    # newgrp - $groupname
done
