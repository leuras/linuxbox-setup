#!/bin/bash

# color scheme
readonly __ACCENT__="\e[${BOLD};${FG_COLOR_LIGHT_YELLOW}m"
readonly __NORMAL__="\e[${NORMAL};${FG_COLOR_LIGHT_GRAY}m"

readonly __SUCCESS__="\e[${BOLD};${FG_COLOR_LIGHT_GREEN}m"
readonly __FAILURE__="\e[${BOLD};${FG_COLOR_RED}m"
readonly __DEBUG__="\e[${NORMAL};${FG_COLOR_DARK_GRAY}m"

function console::log {
    local message="$1"

    echo -e "${__DEBUG__}${message}${__NORMAL__}"
}

function console::info {
    local message=$(console::highlight "$1")

    echo -e "${__NORMAL__}${message}${__NORMAL__}"
}

function console::success {
    local message=$(console::highlight "$1")

    # \xE2\x9C\x94 is the hex equivalent value to the unicode value U+2714
    echo -e "${__NORMAL__}${message} ${__SUCCESS__}\xE2\x9C\x94${__NORMAL__}"
}

function console::error {
    local message=$(console::highlight "$1")

    # \xE2\x9C\x98 is the hex equivalent value to the unicode value U+2718
    echo -e "${__NORMAL__}${message} ${__FAILURE__}\xE2\x9C\x98${__NORMAL__}"
}

function console::highlight {
    # Looks for the highlight pattern of elements within a given string
    echo "$(echo "$1" | sed -E 's/\^([a-zA-Z \/\._-]+)\^/'"\\${__ACCENT__}"'\1'"\\${__NORMAL__}"'/g')"
}

function console::linebreak {
    echo ""
}
