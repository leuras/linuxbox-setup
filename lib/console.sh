#!/bin/bash

# color scheme
__ACCENT__="\e[${FG_COLOR_LIGHT_YELLOW};${BOLD}m"
__NORMAL__="\e[${FG_COLOR_LIGHT_GRAY};${NORMAL}m"

__SUCCESS__="\e[${FG_COLOR_LIGHT_GREEN};${BOLD}m"
__FAILURE__="\e[${FG_COLOR_RED};${BOLD}m"

function console::info {
    local message=$(console::highlight "$1")

    echo -e "${__NORMAL__}${message}${__NORMAL__}"
}

function console::success {
    local message=$(console::highlight "$1")

    echo -e "${__NORMAL__}${message} ${__SUCCESS__}\u2714${__NORMAL__}"
}

function console::error {
    local message=$(console::highlight "$1")

    echo -e "${__NORMAL__}${message} ${__FAILURE__}\u2718${__NORMAL__}"
}

function console::highlight {
    # Looks for the highlight pattern of elements within a given string
    echo "$(echo "$1" | sed -E 's/\^([a-zA-Z \._-]+)\^/'"\\${__ACCENT__}"'\1'"\\${__NORMAL__}"'/g')"
}

function console::linebreak {
    echo ""
}
