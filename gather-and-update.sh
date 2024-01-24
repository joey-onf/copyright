#!/bin/bash
# -----------------------------------------------------------------------
# Intent: Recursively Iterate over repositories and sources, updating
#   copyright notice to remove syntax anomolies and span current year.
# -----------------------------------------------------------------------

# -----------------------------------------------------------------------
# Copyright 2023-2024 Open Networking Foundation (ONF) and the ONF Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -----------------------------------------------------------------------
# SPDX-FileCopyrightText: 2023-2024 Open Networking Foundation (ONF) and the ONF Contributors
# SPDX-License-Identifier: Apache-2.0
# -----------------------------------------------------------------------

## -----------------------------------------------------------------------
## Intent: Infer paths based on script location
## -----------------------------------------------------------------------
function program_paths()
{
    declare -g pgm="$(readlink --canonicalize-existing "$0")"
    declare -g pgmbin="${pgm%/*}"

    readonly pgm
    readonly pgmbin
    return
}
program_paths

##----------------##
##---]  MAIN  [---##
##----------------##

# 1) Gather a list of files that contain a copyright notice.
# 2) Filter non-ONF copyright notices from the list.
# 3) Invoke morph.pl to remove anomolies and rewrite ending date.

declare -a gargs=()
gargs+=('--binary-files=without-match')
grep -ir "${gargs[@]}" 'copyright' \
    | grep -v -e 'vendor/' \
    | grep --fixed-strings -i -e 'onf' -e '(ONF)' -e 'open networking foundation' \
    | cut -d: -f1 \
    | xargs -n1 "${pgmbin}/morph.pl"

# [EOF]
