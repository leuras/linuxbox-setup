#!/bin/bash

readonly __RAW_JSON__=$(cat package.json)

function packages::get {
    local package="${1}"

    # 1. filters the given package object
    # 2. combines the `URL` and `executable` properties with all properties of `metadata` into a single object
    # 3. converts the merged object into a key/value pair
    # 4. transform each entry into a string like: `[key]="value"`
    # 5. separates each entry by spaces and puts all of it between parentheses, as the following: ([key1]="value1" [key2]="value2" [keyN]="valueN")
    echo "${__RAW_JSON__}" | jq -r '."packages"."'${package}'" | { name: "'${package}'", url, executable } + .metadata | to_entries | map("[\(.key)]=\"\(.value)\"") | "(\(join(" ")))"'
}

function packages::get_ppa {
    local package="${1}"

    # 1. filters the given package object
    # 2. transforms the `categories` property from an array into a string
    # 3. converts the object into a key/value pair
    # 4. transform each entry into a string like: `[key]="value"`
    # 5. separates each entry by spaces and puts all of it between parentheses, as the following: ([key1]="value1" [key2]="value2" [keyN]="valueN")
    echo "${__RAW_JSON__}" | jq -r '."custom-ppa-repositories"."'${package}'" | { name: "'${package}'" } + . + { categories: .categories | join(" ") } | to_entries | map("[\(.key)]=\"\(.value)\"") | "(\(join(" ")))"'
}

function packages::list {
    local group="${1}"

    # 1. filters the given group package
    # 2. extracts all the keys (property names) of the given group
    # 3. returns the array keys as a string (-c instructs jq to compact the output)
    echo "${__RAW_JSON__}" | jq -rc '."'${group}'" | keys | .[]' 2> /dev/null
}

function packages::groups {
    # 1. extracts all the keys (property names) from the root node
    # 2. returns the array keys as a string (-c instructs jq to compact the output)
    echo "${__RAW_JSON__}" | jq -rc '. | keys | .[]' 2> /dev/null
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

function packages::executables {
    # 1. combines the `package` and `custom-ppa-repositories` properties into a single object
    # 2. converts the merged object into a key/value pair
    # 3. maps all values to the `executable`
    # 2. 
    echo "${__RAW_JSON__}" | jq -rc '."packages" + ."custom-ppa-repositories" | to_entries | map({(.key|tostring): .value.executable}) | add | keys | .[]'
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
