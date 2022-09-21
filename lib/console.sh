#!/bin/bash

function console::header {
    local message="$1"

    local frame_style="\e[${FG_COLOR_CYAN};${BOLD}m"
    local title_style="\e[${FG_COLOR_LIGHT_GREEN}m"
    local reset_style="\e[${FG_COLOR_DEFAULT};${NORMAL}m"

    local title="${title_style}${message}${frame_style}"

    echo -e "${frame_style}"
    echo -e "==============================( $title )=============================="
    echo -e "${reset_style}"
}

function console::title {
    local message="$1"

    echo -e "\n\e[${FG_COLOR_LIGHT_YELLOW};${BOLD}m[*] \e[${FG_COLOR_LIGHT_GREEN}m${message}\e[${FG_COLOR_DEFAULT};${NORMAL}m"
}

function console::info {
    local message="$1"

    echo -e "\e[${FG_COLOR_CYAN};${BOLD}m[i] \e[${FG_COLOR_LIGHT_YELLOW}m${message}\e[${FG_COLOR_DEFAULT};${NORMAL}m"
}

function console::notice {
    local message="$1"

    echo -e "\e[${FG_COLOR_LIGHT_MAGENTA};${BOLD}m[!] \e[${FG_COLOR_LIGHT_YELLOW}m${message}\e[${FG_COLOR_DEFAULT};${NORMAL}m"
}

function console::log {
    local message="$1"

    echo -e "\e[${FG_COLOR_DARK_GRAY}m${message}\e[${FG_COLOR_DEFAULT};${NORMAL}m"
}

function console::break_line {
    echo ""
}

function console::pad_end {
    local value="$1"
    local char="$2"
    local length="$3"

    local chars=$(echo "${value}" | wc -c)
    local limit=$(($length - $chars))

    local new_value="${value}"

    for i in $(seq 1 $limit); do
        new_value="${new_value}${char}"
    done

    echo "${new_value}"
}
