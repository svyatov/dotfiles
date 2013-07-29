#!/bin/bash

set -e

CURRENT_DIR="${HOME}/.dotfiles"
# Git
GIT_CONFIG_FILE="${HOME}/.gitconfig"
# Ruby
GEM_CONFIG_FILE="${HOME}/.gemrc"
IRB_CONFIG_FILE="${HOME}/.irbrc"
RAILS_CONFIG_FILE="${HOME}/.railsrc"
# Zsh
ZSH_RC_FILE="${HOME}/.zshrc"
ZSH_ENV_FILE="${HOME}/.zshenv"
ZSH_PROFILE_FILE="${HOME}/.zprofile"
OH_MY_ZSH_DIR="${HOME}/.oh-my-zsh"
# Others
TMUX_CONFIG_FILE="${HOME}/.tmux.conf"
VIM_CONFIG_FILE="${HOME}/.vimrc"
VIM_VUNDLE_DIR="${HOME}/.vim/bundle/vundle"

### Helpers
############
function backup_file() {
    if [[ -f $1 && ! -L $1 ]]; then
        if /bin/mv "${1}" "${1}.orig"; then
            echo "File ${1} is backed up successfully!"
        fi
    fi
}

function symlink_from_dotfiles() {
    # s - symlink
    # h - do not follow symlink if exists
    # f - overwrite symlink if exists
    /bin/ln -shf "${CURRENT_DIR}/${1}" "${2}"
}

### Setting up git
###################
backup_file "${GIT_CONFIG_FILE}"
symlink_from_dotfiles "git/.gitconfig" "${GIT_CONFIG_FILE}"

### Setting up zsh
###################
if [[ ! -d ${OH_MY_ZSH_DIR} ]]; then
    /usr/bin/env git clone "git://github.com/robbyrussell/oh-my-zsh.git" "${OH_MY_ZSH_DIR}"
fi
backup_file "${ZSH_RC_FILE}"
symlink_from_dotfiles "zsh/.zshrc" "${ZSH_RC_FILE}"
backup_file "${ZSH_ENV_FILE}"
symlink_from_dotfiles "zsh/.zshenv" "${ZSH_ENV_FILE}"
backup_file "${ZSH_PROFILE_FILE}"
symlink_from_dotfiles "zsh/.zprofile" "${ZSH_PROFILE_FILE}"

### Setting up ruby: rails, irb, gem
#####################################
backup_file "${GEM_CONFIG_FILE}"
symlink_from_dotfiles "ruby/.gemrc" "${GEM_CONFIG_FILE}"
backup_file "${IRB_CONFIG_FILE}"
symlink_from_dotfiles "ruby/.irbrc" "${IRB_CONFIG_FILE}"
backup_file "${RAILS_CONFIG_FILE}"
symlink_from_dotfiles "ruby/.railsrc" "${RAILS_CONFIG_FILE}"

### Setting up vim
##################
backup_file "${VIM_CONFIG_FILE}"
symlink_from_dotfiles "other/.vimrc" "${VIM_CONFIG_FILE}"
if [[ ! -d ${VIM_VUNDLE_DIR} ]]; then
    /usr/bin/env git clone "https://github.com/gmarik/vundle.git" "${VIM_VUNDLE_DIR}"
    /usr/bin/env vim +BundleInstall +qall
fi

### Setting up others
######################
backup_file "${TMUX_CONFIG_FILE}"
symlink_from_dotfiles "other/.tmux.conf" "${TMUX_CONFIG_FILE}"
