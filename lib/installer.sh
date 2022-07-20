#!/bin/bash

readonly __LINUXBOX_SETUP_DIR="/tmp/linuxbox-setup-$(cat /proc/sys/kernel/random/uuid)"

get_installer () {
    local url="$1"
    local binary="$2"

    mkdir -p "${__LINUXBOX_SETUP_DIR}"
    wget -v -O "${__LINUXBOX_SETUP_DIR}/${binary}" "${url}"
}

install_deb_package () {
    local binary="$1"

    gdebi "${__LINUXBOX_SETUP_DIR}/${binary}"
}

deb_package_installed () {
    local package="$1"

    echo "$(dpkg-query -W -f='${Status}' ${package} 2> /dev/null)"
}

binary_installed () {
    local binary="$1"

    echo "$(command -v ${binary} 2> /dev/null)"
}

delete_temp_files () {
    rm -rf "${__LINUXBOX_SETUP_DIR}"
}
