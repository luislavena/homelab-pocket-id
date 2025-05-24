#!/usr/bin/env sh

set -e

APP=/app/pocket-id
APP_PATH=$(dirname ${APP})

export APP_NAME=$(basename ${APP})
export DB_NAME=pocket-id.db
export DB_PATH=${APP_PATH}/data

if [ ! -d "${DB_PATH}" ]; then
    echo "INFO: Creating database directory ${DB_PATH}..."
    mkdir -p "${DB_PATH}"
fi

echo "INFO: Attempting to restore database if missing..."
litestream restore -if-db-not-exists -if-replica-exists ${DB_PATH}/${DB_NAME}

cd ${APP_PATH}

echo "INFO: Starting application using Litestream..."
exec litestream replicate -exec ${APP}
