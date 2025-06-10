#!/usr/bin/env sh

set -e

APP=/app/pocket-id
APP_PATH=$(dirname ${APP})

export APP_NAME=$(basename ${APP})
export DB_NAME=pocket-id.db
export DB_PATH=${APP_PATH}/data

setup() {
    local jwt_private_key_file=${DB_PATH}/keys/jwt_private_key.json

    # check if JWT private key file exists
    if [ ! -f "${jwt_private_key_file}" ]; then

        # use JWT_PRIVATE_KEY environment variable if found
        if [ -z "${JWT_PRIVATE_KEY}" ]; then
            echo "WARN: JWT private key does not exist and one will be randomly generated" >&2
        else
            mkdir -p "${DB_PATH}/keys"

            echo "${JWT_PRIVATE_KEY}" | base64 -d > "${jwt_private_key_file}"
            echo "INFO: JWT private key created from JWT_PRIVATE_KEY variable"
        fi
    fi
}

# prepare configuration
setup

if [ ! -d "${DB_PATH}" ]; then
    echo "INFO: Creating database directory ${DB_PATH}..."
    mkdir -p "${DB_PATH}"
fi

echo "INFO: Attempting to restore database if missing..."
litestream restore -if-db-not-exists -if-replica-exists ${DB_PATH}/${DB_NAME}

cd ${APP_PATH}

echo "INFO: Starting application using Litestream..."
exec litestream replicate -exec ${APP}
