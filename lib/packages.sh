#!/bin/bash

readonly __RAW_JSON__=$(cat package.json)

function packages::get {
    local package="${1}"

    # 1. filters by the given package object
    # 2. combines the `URL` and `executable` properties with all properties of `metadata` into a single object
    # 3. converts the merged object into a key/value pair
    # 4. transform each entry into a string like: `[key]="value"`
    # 5. separates each entry by spaces and puts all of it between parentheses, as the following: ([key1]="value1" [key2]="value2" [keyN]="valueN")
    echo "${__RAW_JSON__}" | jq -r '."binary-packages"."'${package}'" | { name: "'${package}'", url, executable } + .metadata | to_entries | map("[\(.key)]=\"\(.value)\"") | "(\(join(" ")))"' 2> /dev/null
}

function packages::get_ppa {
    local package="${1}"

    # 1. filters by the given package object
    # 2. transforms the `categories` property from an array into a string
    # 3. converts the object into a key/value pair
    # 4. transform each entry into a string like: `[key]="value"`
    # 5. separates each entry by spaces and puts all of it between parentheses, as the following: ([key1]="value1" [key2]="value2" [keyN]="valueN")
    echo "${__RAW_JSON__}" | jq -r '."custom-ppa-repositories"."'${package}'" | { name: "'${package}'" } + . + { categories: .categories | join(" ") } | to_entries | map("[\(.key)]=\"\(.value)\"") | "(\(join(" ")))"' 2> /dev/null
}

function packages::system_requirements {
    echo "${__RAW_JSON__}" | jq -rc '."system-requirements" | join(" ")' 2> /dev/null
}

function packages::list {
    local group="${1}"

    # 1. filters by the given group package
    # 2. extracts all the keys (property names) of the given group
    # 3. if the element is an object, it will extract all of its keys. Otherwise, it will return the element itself.
    # 4. returns all entries as a string separated by a space (-c instructs jq to compact the output)
    echo "${__RAW_JSON__}" | jq -rc '."'${group}'" | if type == "object" then keys else . end | join(" ")' 2> /dev/null
}

function packages::executables {
    # 1. filters all executables using the recursive descent statement (..)
    # 2. combines the prior result with the all ppa packages
    # 3. returns all entries as a string separated by a space (-c instructs jq to compact the output)
    echo "${__RAW_JSON__}" | jq -rc '[..|.executable? | select(. != null)] + ."ppa-packages" | join(" ")' 2> /dev/null
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
    # evaluates the package associative array received through `typeset`
    eval "${@}"

    [[ "${package[direct-link]}" == "true" ]] && local url="${package[url]}" || local url=$(packages::latest_url "$(typeset -p package)")
        
    echo "${url}"
}

function packages::latest_url {
    # evaluates the package associative array received through `typeset`
    eval "${@}"

    local extension=$(packages::extension "${package[type]}")

    echo "$(curl -sL "${package[url]}" | grep -Eio "(https?:\/{2}[a-z0-9\._?=\/-]+${package[release-name]}[a-z0-9_\.-]*\.?${extension})" | uniq | head -n 1)"
}
