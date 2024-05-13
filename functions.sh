#!/usr/bin/env bash

# Copy/move functions in /opt/functions/ on source
if ! [ -d /opt/functions ]; then
    mkdir --parents /opt/functions || return 1
fi

if command -v rsync; then
    rsync --archive  \
        --partial \
        --include="*functions.sh" \
        --exclude="*" . /opt/functions
else
    cp ./*functions.sh /opt/functions
fi


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
