#!/bin/bash

# oh-my-zsh variables
readonly __OH_MY_ZSH__=${ZSH:-"${HOME}/.oh-my-zsh"}
readonly __INSTALLER__="/tmp/ohmyzsh-install.sh"
readonly __THEMES__="${__OH_MY_ZSH__}/custom/themes"
readonly __SPACESHIP_HOME__="${__THEMES__}/spaceship-prompt"

function oh_my_zsh::install {
    local current_shell="${SHELL}"
    local zsh_shell="$(which zsh)"

    # sets the zsh as the current login shell
    if [[ "${zsh_shell}" != "${current_shell}" ]]; then
        console::info "Switching the current shell from ^${current_shell}^ to ^${zsh_shell}^ ..."
        chsh -s $zsh_shell
        console::info "The current shell now is ^${SHELL}^."
    else
        console::log "The current shell already is ${zsh_shell}."
    fi

    # installs the oh-my-zsh framework
    if [[ ! -d "${__OH_MY_ZSH__}" ]]; then
        console::info "Trying to install ^Oh-my-zsh^ ..."
        console::linebreak

        curl -fsSL "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" > "${__INSTALLER__}"
        chmod +x "${__INSTALLER__}" && "${__INSTALLER__}"
    else
        console::log "Oh-my-zsh is already installed."
    fi
}

function oh_my_zsh::set_theme {
    if [[ ! -d "${__SPACESHIP_HOME__}" ]]; then
        console::info "Trying to install ^Spaceship-Prompt Theme^ ..."
        console::linebreak

        git clone --depth=1 "https://github.com/spaceship-prompt/spaceship-prompt.git" "${__SPACESHIP_HOME__}"
        ln -s "${__SPACESHIP_HOME__}/spaceship.zsh-theme" "${__THEMES__}/spaceship.zsh-theme"
    else
        console::log "Spaceship-Prompt Theme is already installed."
    fi    
}

function oh_my_zsh::summary {
    declare -A items=(["Oh-my-zsh"]="${__OH_MY_ZSH__}" ["Spaceship-Prompt Theme"]="${__SPACESHIP_HOME__}")

    for key in "${!items[@]}"; do
        if [[ -d "${items[$key]}" ]]; then
            console::success "^${key}^ is installed"
        else
            console::error "^${key}^ is not installed"
        fi
    done
}

function oh_my_zsh::pos_install {
    # source "${HOME}/.zshrc"
    rm -f "${__INSTALLER__}"
}