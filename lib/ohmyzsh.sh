#!/bin/bash

# oh-my-zsh variables
readonly __OH_MY_ZSH__=${ZSH:-"${HOME}/.oh-my-zsh"}
readonly __INSTALLER__="/tmp/ohmyzsh-install.sh"
readonly __THEMES__="${__OH_MY_ZSH__}/custom/themes"
readonly __SPACESHIP_HOME__="${__THEMES__}/spaceship-prompt"
readonly __RESOURCES_PATH__="${__BASE_DIR__}/resources"
readonly __ZSHRC__="${HOME}/.zshrc"

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
        chmod +x "${__INSTALLER__}" && "${__INSTALLER__}" --unattended
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
        console::linebreak

        console::info "Backupping ^.zshrc^ file ..."
        cp "${__ZSHRC__}" "${__ZSHRC__}~" 2> /dev/null
        
        console::info "Defining ^plugins section^ ..."
        sed -i 's/\(plugins\)=([a-zA-Z0-9\s_\-]\+)/\1=(git fzf)/' "${__ZSHRC__}" 2> /dev/null

        console::info "Defining ^spaceshipt-prompt^ as the theme  ..."
        sed -i 's/\(ZSH_THEME\)="[a-zA-Z0-9\-]\+"/\1="spaceship"/' "${__ZSHRC__}" 2> /dev/null

        console::info "Configuring ^spaceshipt-prompt^ theme ..."
        cp "${__RESOURCES_PATH__}/.spaceshiprc.zsh" "${HOME}" 2> /dev/null
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