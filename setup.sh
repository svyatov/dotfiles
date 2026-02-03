#!/bin/bash

set -e

DOTFILES_DIR="${HOME}/.dotfiles"
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
ZSH_LOGIN_FILE="${HOME}/.zlogin"
# Zsh Prezto
ZPREZTO_DIR="${HOME}/.zprezto"
ZPREZTO_RC_FILE="${HOME}/.zpreztorc"
# Others
TMUX_CONFIG_FILE="${HOME}/.tmux.conf"
NEOVIM_CONFIG_DIR="${HOME}/.config/nvim"
NEOVIM_CONFIG_FILE="${NEOVIM_CONFIG_DIR}/init.vim"
# VIM_CONFIG_FILE="${HOME}/.vimrc"
# VIM_VUNDLE_DIR="${HOME}/.vim/bundle/Vundle.vim"
SECRETS_FILE="${HOME}/.secrets"

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
    /bin/ln -shf "${DOTFILES_DIR}/${1}" "${2}"
}

### Setting up git
###################
backup_file "${GIT_CONFIG_FILE}"
symlink_from_dotfiles "git/.gitconfig" "${GIT_CONFIG_FILE}"

### Setting up zsh
###################
if [[ ! -d ${ZPREZTO_DIR} ]]; then
    /usr/bin/env git clone --recursive "https://github.com/sorin-ionescu/prezto.git" "${ZPREZTO_DIR}"
fi
backup_file "${ZSH_RC_FILE}"
symlink_from_dotfiles "zsh/.zshrc" "${ZSH_RC_FILE}"
backup_file "${ZSH_ENV_FILE}"
symlink_from_dotfiles "zsh/.zshenv" "${ZSH_ENV_FILE}"
backup_file "${ZSH_LOGIN_FILE}"
symlink_from_dotfiles "zsh/.zlogin" "${ZSH_LOGIN_FILE}"
backup_file "${ZPREZTO_RC_FILE}"
symlink_from_dotfiles "zsh/.zpreztorc" "${ZPREZTO_RC_FILE}"
symlink_from_dotfiles "zsh/prompt_svyatov_setup" "${ZPREZTO_DIR}/modules/prompt/functions/prompt_svyatov_setup"
backup_file "${ZSH_PROFILE_FILE}" # just "remove" .zprofile because it's useless

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
# backup_file "${VIM_CONFIG_FILE}"
# symlink_from_dotfiles "other/.vimrc" "${VIM_CONFIG_FILE}"
# if [[ ! -d ${VIM_VUNDLE_DIR} ]]; then
#     /usr/bin/env git clone "https://github.com/gmarik/vundle.git" "${VIM_VUNDLE_DIR}"
#     /usr/bin/env vim +BundleInstall +qall

### Setting up neovim
#################
mkdir -p "${NEOVIM_CONFIG_DIR}"
backup_file "${NEOVIM_CONFIG_FILE}"
symlink_from_dotfiles "nvim/init.vim" "${NEOVIM_CONFIG_FILE}"

### Setting up others
######################
# backup_file "${TMUX_CONFIG_FILE}"
# symlink_from_dotfiles "other/.tmux.conf" "${TMUX_CONFIG_FILE}"
touch "${SECRETS_FILE}"

### Setting up Claude Code
##########################
CLAUDE_CONFIG_DIR="${HOME}/.claude"
mkdir -p "${CLAUDE_CONFIG_DIR}"

# Symlink settings and statusline
backup_file "${CLAUDE_CONFIG_DIR}/settings.json"
symlink_from_dotfiles "claude/settings.json" "${CLAUDE_CONFIG_DIR}/settings.json"
symlink_from_dotfiles "claude/statusline-command.sh" "${CLAUDE_CONFIG_DIR}/statusline-command.sh"

echo ""
echo "Claude Code setup complete."
echo "To install plugins, run: ~/.dotfiles/claude/install-plugins.sh"
echo "To install skills, run: ~/.dotfiles/claude/install-skills.sh"
