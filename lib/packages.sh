#!/bin/bash

readonly __RAW_JSON__=$(cat package.json)

function packages::get {
    local package="$1"

    # 1. filters the given package object
    # 2. combines the `URL` and `executable` properties with all properties of `metadata` into a single object
    # 3. converts the merged object into a key/value pair
    # 4. transform each entry into a string like: `[key]="value"`
    # 5. separates each entry by spaces and puts all of it between parentheses, as the following: ([key1]="value1" [key2]="value2" [keyN]="valueN")
    echo "${__RAW_JSON__}" | jq -r '."packages"."'${package}'" | { name: "'${package}'", url, executable } + .metadata | to_entries | map("[\(.key)]=\"\(.value)\"") | "(\(join(" ")))"'
}

function packages::extension {
    local type="${1}"

    case "${type}" in
        "DEB")
            echo "deb"
        ;;
        *) 
            echo ""
        ;;
    esac
}

function packages::url {
    local package="${@}"

    [[ "${package[direct-link]}" == "true" ]] && local url="${package[url]}" || local url=$(packages::latest_url "${package[@]}")
        
    echo "${url}"
}

function packages::latest_url {
    local package="${@}"
    local extension=$(packages::extension "${package[type]}")

    echo "$(curl -sL "${package[url]}" | grep -Eio "(https?:\/{2}[a-z0-9\._?=\/-]+${package[release-name]}[a-z0-9_\.-]*\.?${extension})" | uniq | head -n 1)"
}
