#!/bin/bash
## -----------------------------------------------------------------------
## Intent: Generate a dated copyright notice
## -----------------------------------------------------------------------

##-------------------##
##---]  GLOBALS  [---##
##-------------------##
# declare -g start_year
declare -g end_year

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function error()
{
    echo "** ERROR $0::${FUNCNAME[1]}: $*"
    exit 1
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function init()
{
    end_year="$(date '+%Y')"
    return
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function get_template
{
    declare -n ans=$1; shift

    local pgmdir="${0%/*}"
    local pgmabs="$(realpath "$pgmdir")"
    local template="$pgmabs/copyright.tmpl"
    readarray -t tmp <"$template"

    ans=("${tmp[@]}")
    return
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function usage()
{
    [[ $# -gt 0 ]] && echo "** $*"

    local onf_suffix='Open Networking Foundation (ONF) and the ONF Contributors'

    cat <<EOH
Usage: $0 [options] ...
Options:
  --start [year]       Optional copyright notice start date.
  --end   [year]       Ending copyright notice date (default: now)
  --help               This mesage

% ./gen-copyright.sh
Copyright 2023 $onf_suffix

% ./gen-copyright.sh --start 2019
Copyright 2019-2023 $onf_suffix

% ./gen-copyright.sh --end 2024
Copyright 2024 $onf_suffix
EOH
    return
}

##----------------##
##---]  MAIN  [---##
##----------------##
init

while [ $# -gt 0 ]; do
    arg="$1"; shift
    case "$arg" in
	-*start*)
	    declare -i -g start_year="$1";
	    shift
	    ;;
	-*end*) end_year="$1"; shift ;;
	-*help) usage; exit 0 ;;
	*) error "Detected unknown switch [$arg] $*" ;;
    esac
done

declare -a tmpl
get_template tmpl

datestr="$end_year"
[[ -v start_year ]] && datestr="${start_year}-${end_year}"

declare -a out=()
for line in "${tmpl[@]}";
do
    out+=("${line//<|copyright-date|>/${datestr}}")
    echo "${out[-1]}"
done

# [EOF]
