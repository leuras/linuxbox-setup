#!/bin/bash

# private variables
readonly __LINUXBOX_SETUP_DIR="/tmp/linuxbox-setup-$(cat /proc/sys/kernel/random/uuid)"
readonly __APT_KEYRING_DIR="/etc/apt/keyrings"

function install_package {
    local package="$1"
    local properties="$2"

    local status=$(__is_installed "${package}")

    if [[ -z "${status}" ]]; then

        local url=$(json_value "$properties" ".url")
        local metadata="$(json_value "${properties}" ".metadata")"
        local resolved_url=$(__resolve_url "${package}" "${url}" "${metadata}")

        local package_type=$(json_value "${metadata}" ".type")
        local extension=$(__package_extension "${package_type}")
        
        [[ -z "${extension}" ]] && local binary="${package}" || local binary="${package}.${extension}"

        __get_package "${resolved_url}" "${binary}"

        case "${package_type}" in 
            "DEB")
                __install_deb "$binary"
            ;;
            "BINARY")
                __install_binary "${binary}"
            ;;
        esac
    else
        echo "Package ${package} is already installed."
    fi
}

function add_custom_ppa {
    local package="$1"
    local properties="$2"

    local status=$(__is_installed "${package}")

    if [[ -z "${status}" ]]; then

        local gpg_url=$(json_value "${properties}" ".gpg-url")
        local ppa_url=$(json_value "${properties}" ".ppa-url")
        local distribution=$(json_value "${properties}" ".distribution")
        local categories_array=$(json_value "${properties}" ".categories")
        local categories=$(json_array_to_string_list "${categories_array}")

        local keyring_file="${__APT_KEYRING_DIR}/${package}.gpg"
        local content="deb [arch=$(dpkg --print-architecture) signed-by=${keyring_file}] ${ppa_url} ${distribution} ${categories}"
        
        mkdir -p "${__APT_KEYRING_DIR}"
        curl -fsSL "${gpg_url}" | gpg --dearmor -o "${keyring_file}"
        echo "${content}" | tee "/etc/apt/sources.list.d/${package}.list" > /dev/null
    fi
}

function cleanup_installation {
    rm -rf "${__LINUXBOX_SETUP_DIR}"
}

function __is_installed {
    local binary="$1"

    echo "$(command -v ${binary} 2> /dev/null)"
}

function __resolve_url {
    local package="$1"
    local url="$2"
    local metadata="$3" 

    local direct_link=$(json_value "${metadata}" ".direct-link")
    
    if [[ "${direct_link}" == "false" ]]; then
        echo "$(__latest_release "${url}" "${metadata}")"
    else
        echo "${url}"
    fi
}

function __latest_release {
    local url="$1"
    local metadata="$2"

    local release=$(json_value "${metadata}" ".release-name")
    local package_type=$(json_value "${metadata}" ".type")
    local extension=$(__package_extension "${package_type}")

    echo "$(curl -sL "${url}" | grep -Eio "(https?:\/{2}[a-z0-9\._?=\/-]+${release}[a-z0-9_\.-]*\.?${extension})" | uniq | head -n 1)"    
}

function __package_extension {
    local package_type="$1"

    case "${package_type}" in
        "DEB")
            echo "deb"
        ;;
        *) 
            echo ""
        ;;
    esac
}

function __get_package {
    local url="$1"
    local binary="$2"
    
    mkdir -p "${__LINUXBOX_SETUP_DIR}"
    wget -v -O "${__LINUXBOX_SETUP_DIR}/${binary}" "${url}"
}

function __install_deb {
    local binary="$1"

    gdebi -n "${__LINUXBOX_SETUP_DIR}/${binary}"
}

function __install_binary {
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
