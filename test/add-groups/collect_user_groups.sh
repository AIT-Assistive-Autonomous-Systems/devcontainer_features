#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Copyright (c) Austrian Institute of Technology. All rights reserved.
# Licensed under the MIT License. See https://github.com/AIT-Assistive-Autonomous-Systems/devcontainer_features/blob/main/LICENSE for license information.
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Maintainer: * @AIT-Assistive-Autonomous-Systems/maintainers
# Outputs the user groups directly from groups

set -eu

USER=${1}

set -eu

awk -F':' -v OFS=',' /$USER/'{print $3"("$1")"}' /etc/group | tr '\n' ',' | sed 's/,$/\n/'
