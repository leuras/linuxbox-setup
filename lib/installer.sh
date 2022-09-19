#!/bin/bash

# private variables
readonly __LINUXBOX_SETUP_DIR="/tmp/linuxbox-setup-$(cat /proc/sys/kernel/random/uuid)"

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
