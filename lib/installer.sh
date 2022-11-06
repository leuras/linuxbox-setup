#!/bin/bash

readonly __KEYRING_DIR="/etc/apt/keyrings"
readonly __LINUXBOX_SETUP_DIR="/tmp/linuxbox-setup-$(cat /proc/sys/kernel/random/uuid)"
readonly __SUDO=$(which sudo)

function install_package {
    declare -A package=$(packages::get "$1")

    local status=$(is_installed "${package[executable]}")

    if [[ -z "${status}" ]]; then

        local url=$(packages::url "${package[@]}")
        local extension=$(packages::extension "${package[type]}")
        
        [[ -z "${extension}" ]] && local binary="${package[name]}" || local binary="${package[name]}.${extension}"

        __get_package "${url}" "${binary}"

        case "${package_type}" in 
            "DEB")
                __install_deb "$binary"
            ;;
            "BINARY")
                __install_binary "${binary}"
            ;;
        esac
    else
        console::log "Package ${package[name]} is already installed."
    fi
}

function add_custom_ppa {
    local package="$1"
    local properties="$2"

    local executable=$(json_value "$properties" ".executable")
    local status=$(is_installed "${executable}")

    if [[ -z "${status}" ]]; then

        local gpg_url=$(json_value "${properties}" ".gpg-url")
        local ppa_url=$(json_value "${properties}" ".ppa-url")
        local distribution=$(json_value "${properties}" ".distribution")
        local categories_array=$(json_value "${properties}" ".categories")
        local categories=$(json_array_to_string_list "${categories_array}")

        local keyring_file="${__KEYRING_DIR}/${package}.gpg"
        local content="deb [arch=$(dpkg --print-architecture) signed-by=${keyring_file}] ${ppa_url} ${distribution} ${categories}"
        
        $__SUDO mkdir -p "${__KEYRING_DIR}"
        curl -fsSL "${gpg_url}" | $__SUDO gpg --dearmor -o "${keyring_file}"
        echo "${content}" | $__SUDO tee "/etc/apt/sources.list.d/${package}.list" > /dev/null
    else
        console::log "Package ${package} is already installed."
    fi
}

function apt_install {
    local packages=("$@")
    
    $__SUDO apt update && $__SUDO apt install -y "${packages[@]}"
}

function is_installed {
    local binary="$1"

    echo "$(command -v ${binary} 2> /dev/null)"
}

function cleanup_installation {
    rm -rf "${__LINUXBOX_SETUP_DIR}"
}

function __get_package {
    local url="$1"
    local binary="$2"
    
    mkdir -p "${__LINUXBOX_SETUP_DIR}"
    wget -v -O "${__LINUXBOX_SETUP_DIR}/${binary}" "${url}"
}

function __install_deb {
    local binary="$1"

    $__SUDO gdebi -n "${__LINUXBOX_SETUP_DIR}/${binary}"
}

function __install_binary {
    local package="$1"

    local binary="${__LINUXBOX_SETUP_DIR}/${package}"
    local file_info=$(file -b "${binary}" | awk -F "," '{print $1}')

    case "${file_info}" in
        "ELF 64-bit LSB executable")
            local installation_path="/usr/local/bin/${package}"

            $__SUDO cp "${binary}" "${installation_path}"
            $__SUDO chmod +x "${installation_path}"
            ;;
        "gzip compressed data")
            local installation_path="/opt/${package}"

            $__SUDO mkdir -p "${installation_path}"
            $__SUDO tar -xvzf "${binary}" -C "${installation_path}"
            ;;
    esac
}
