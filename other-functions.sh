#!/usr/bin/env bash

# shellcheck disable=SC1091
if ! source /opt/functions/functions.sh; then
    echo "Error! Could not source functions.sh"
    return 1
fi

function apply_from_dotfiles() {
    log_info "Apply configuration from dotfiles"
    local RETURN_VALUE=0

    DOTFILES_DIR_NAME="dotfiles"
    DOTFILES="$(find "${HOME}" -type d -name "${DOTFILES_DIR_NAME}")"
    
    for directory in $DOTFILES;do
        pushd "${directory}" || RETURN_VALUE=1

        if git status &> /dev/null; then
            log_info "Found ${directory}"

            git checkout main &> /dev/null && \
                git pull || RETURN_VALUE=1

            log_info "Syncing configuration"
            rsync --archive \
                --progress \
                --partial \
                --exclude="README.md" \
                --exclude="\.git*" \
                --exclude="\.linters*" . "${HOME}"

            # Exit loop because folder was found
            break
        fi

        popd || RETURN_VALUE=1
    done

    # popd again - notice the positioning of break statement
    if [ "$(dirs -l -p | wc -l)" -gt 1 ]; then
        popd || RETURN_VALUE=1
    else
        log_error "No ${DOTFILES_DIR_NAME} directory found"
        RETURN_VALUE=1
    fi

    log_ok "DONE"
    return "${RETURN_VALUE}"
}
