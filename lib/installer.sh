#!/bin/bash

readonly __KEYRING_DIR="/etc/apt/keyrings"
readonly __SETUP_DIR="/tmp/linuxbox-setup-$(cat /proc/sys/kernel/random/uuid)"
readonly __SUDO=$(which sudo)

function installer::install_from_apt {
    local packages=("$@")
    
    $__SUDO apt update && $__SUDO apt install -y "${packages[@]}"
}

function installer::install_from_archive {
    declare -A package=$(packages::get "${1}")

    if [[ ! $(installer::already_installed "${package[executable]}") ]]; then

        local url=$(packages::url "${package[@]}")
        local extension=$(packages::extension "${package[type]}")
        
        [[ -z "${extension}" ]] && local binary="${package[name]}" || local binary="${package[name]}.${extension}"

        installer::download_package "${url}" "${binary}"

        case "${package_type}" in 
            "DEB")
                installer::install_from_deb "$binary"
            ;;
            "BINARY")
                installer::install_from_binary "${binary}"
            ;;
        esac
    else
        console::log "Package ${package[name]} is already installed."
    fi
}

function installer::add_custom_ppa {
    declare -A package=$(packages::get_ppa "${1}")

    if [[ ! $(installer::already_installed "${package[executable]}") ]]; then

        local keyring_file="${__KEYRING_DIR}/${package[name]}.gpg"
        local content="deb [arch=$(dpkg --print-architecture) signed-by=${keyring_file}] ${package[ppa-url]} ${package[distribution]} ${package[categories]}"
        
        $__SUDO mkdir -p "${__KEYRING_DIR}"

        curl -fsSL "${package[gpg-url]}" | $__SUDO gpg --dearmor -o "${keyring_file}"
        echo "${content}" | $__SUDO tee "/etc/apt/sources.list.d/${package}.list" > /dev/null
    else
        console::log "Package ${package[name]} is already installed."
    fi
}

function installer::already_installed {
    local binary="${1}"

    echo "$(command -v ${binary} 2> /dev/null)"
}

function installer::download_package {
    local url="${1}"
    local binary="${2}"
    
    mkdir -p "${__SETUP_DIR}"
    wget -v -O "${__SETUP_DIR}/${binary}" "${url}"
}

function installer::install_from_deb {
    local binary="${1}"

    $__SUDO gdebi -n "${__SETUP_DIR}/${binary}"
}

function installer::install_from_binary {
    local package="${1}"

    local binary="${__SETUP_DIR}/${package}"
    local file_info=$(file -b "${binary}" | awk -F "," '{print ${1}}')

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

function installer::cleanup {
    rm -rf "${__SETUP_DIR}"
}
