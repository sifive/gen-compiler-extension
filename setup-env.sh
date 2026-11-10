#!/usr/bin/env bash
# Source this file to activate the shared SWQA virtual environment.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    printf 'Source this script with: source %s\n' "$0" >&2
    exit 1
fi

_SWQA_ACTIVATE=/nfs/teams/sw/static/swqa/venv/stable/bin/activate
if [[ ! -r "$_SWQA_ACTIVATE" ]]; then
    printf 'Cannot read virtual environment activation script: %s\n' "$_SWQA_ACTIVATE" >&2
    unset _SWQA_ACTIVATE
    return 1
fi

source "$_SWQA_ACTIVATE"
_SWQA_STATUS=$?
unset _SWQA_ACTIVATE
return "$_SWQA_STATUS"
