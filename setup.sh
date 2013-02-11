#!/bin/bash

set -e

CURRENT_DIR=`pwd`
GIT_CONFIG_FILE="${HOME}/.gitconfig"
GEM_CONFIG_FILE="${HOME}/.gemrc"
IRB_CONFIG_FILE="${HOME}/.irbrc"
RAILS_CONFIG_FILE="${HOME}/.railsrc"

### Helpers
############
function backup_file() {
    if [[ -f $1 && ! -L $1 ]]; then
        if mv "${1}" "${1}.orig"; then
            echo "File ${1} is backed up successfully!"
        fi
    fi
}

### Setting up git
###################
backup_file "${GIT_CONFIG_FILE}"

# s: symlink
# h: do not follow symlink if exists
# f: overwrite symlink if exists
ln -shf "${CURRENT_DIR}/git/.gitconfig" "${GIT_CONFIG_FILE}"

### Setting up ruby: rails, irb, gem
#####################################
backup_file "${GEM_CONFIG_FILE}"
backup_file "${IRB_CONFIG_FILE}"
backup_file "${RAILS_CONFIG_FILE}"

ln -shf "${CURRENT_DIR}/ruby/.gemrc" "${GEM_CONFIG_FILE}"
ln -shf "${CURRENT_DIR}/ruby/.irbrc" "${IRB_CONFIG_FILE}"
ln -shf "${CURRENT_DIR}/ruby/.railsrc" "${RAILS_CONFIG_FILE}"
