#!/bin/bash

function json_keys {
    local json="$1"
    local path=$(json_path_normalizer "${2:-.}")

    echo "$(echo "${json}" | jq -r ''${path}' | keys' 2> /dev/null)"
}

function json_value {
    local json="$1"
    local path=$(json_path_normalizer "${2:-.}")   

    echo "$(echo "${json}" | jq -r ''${path}'' 2> /dev/null)"
}

function json_path_normalizer {
    local path="$1"

    echo "$(echo ${path} | sed -E 's/([a-z0-9_-]+)/\"\1\"/gi')"
}

function json_array_to_string_list {
    local json="$1"

    echo "$(echo "${json}" | jq -rc '.[]' 2> /dev/null)" 
}

function json_search {
    local json="$1"
    local key="$(json_path_normalizer "$2")"

    echo "$(jq '..|.'${key}'? | select(. != null)')"
}
