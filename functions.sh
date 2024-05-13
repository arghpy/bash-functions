#!/usr/bin/env bash

if ! source /opt/functions/log_functions.sh; then
    echo "Error! Could not source functions.sh"
    return 1
fi

function exit_on_error() {
    local COMMAND="$*"

    if ! eval "${COMMAND}"; then
        log_error "Error encountered. Aborting..."
        exit 1
    fi
}
