#!/bin/bash

readonly __LINUXBOX_SETUP_DIR="/tmp/linuxbox-setup-$(cat /proc/sys/kernel/random/uuid)"

deb () {
    local package="$1"
    local url="$2"
    local use_crawler="${3}"

    local binary="${package}.deb"
    local installation_status=$(__is_deb_package_installed "${package}")

    if [[ -z "${installation_status}" ]]; then

        if [[ "${use_crawler}" == "true" ]]; then
            url=$(__download_link_crawler "${package}" "${url}")
        fi

        __download_package "${url}" "${binary}"
        __install_deb "${binary}"
    fi
}

binary () {
    local package="$1"
    local url="$2"
    local release="${3}"
    local use_crawler="${4}"

    local installation_status=$(__is_binary_installed "${package}")

    if [[ -z "${installation_status}" ]]; then

        if [[ "${use_crawler}" == "true" ]]; then
            url=$(__download_link_crawler "${release}" "${url}" "" "")
        fi

        __download_package "${url}" "${package}"
        __install_binary "${package}"
    fi
}

shell_script () {
    local package="$1"
    local url="$2"

    local binary="${package}.sh"
    local installation_status=$(__is_binary_installed "${package}")

    if [[ -z "${installation_status}" ]]; then

        __download_package "${url}" "${binary}"
        __install_shell_script "${binary}"
    fi
}

custom_ppa () {
    local package="$1"
    local gpg_url="$2"
    local ppa_url="$3"

    local installation_status=$(__is_deb_package_installed "${package}")

    if [[ -z "${installation_status}" ]]; then
        curl -fsSL "${gpg_url}" | apt-key add -
        add-apt-repository "deb [arch=amd64] ${ppa_url} $(lsb_release -cs) stable"
        apt update && apt install "${package}"
    fi
}

cleanup_installation () {
    rm -rf "${__LINUXBOX_SETUP_DIR}"
}

__download_package() {
    local url="$1"
    local binary="$2"

    mkdir -p "${__LINUXBOX_SETUP_DIR}"
    wget -v -O "${__LINUXBOX_SETUP_DIR}/${binary}" "${url}"
}

__install_deb () {
    local binary="$1"

    gdebi "${__LINUXBOX_SETUP_DIR}/${binary}"
}

__install_binary () {
    local package="$1"

    local binary="${__LINUXBOX_SETUP_DIR}/${package}"
    local file_info=$(file -b "${binary}" | awk -F "," '{print $1}')

    case "${file_info}" in
        "ELF 64-bit LSB executable")
            local installation_path="/usr/local/bin/${package}"

            cp "${binary}" "${installation_path}"
            chmod +x "${installation_path}"
            ;;
        "gzip compressed data")
            local installation_path="/opt/${package}"

            mkdir -p "${installation_path}"
            tar -xvzf "${binary}" -C "${installation_path}"
            ;;
    esac
}

__install_shell_script () {
    local binary="${__LINUXBOX_SETUP_DIR}/${1}"

    chmod +x "${binary}" && cat "${binary}" | bash
}

__is_deb_package_installed () {
    local package="$1"

    echo "$(dpkg-query -W -f='${Status}' ${package} 2> /dev/null)"
}

__is_binary_installed () {
    local binary="$1"

    echo "$(command -v ${binary} 2> /dev/null)"
}

__download_link_crawler () {
    local package="$1"
    local url="$2"
    local extension="${3:-deb}"
    local platform="${4:-amd64}"

    echo "$(curl -sL "${url}" | grep -Eio "(https?:\/{2}[a-z0-9\._?=\/-]+${package}[a-z0-9_-]+\.?${extension})" | grep -Ei "${platform}" | uniq)"
}
