#!/usr/bin/env sh

set -e

# Capture APP and DB_FILE from command line arguments
APP=$1
DB_FILE=$2

# Validate that both arguments are provided
if [ -z "$APP" ] || [ -z "$DB_FILE" ]; then
    echo "ERROR: Both APP and DB_FILE arguments are required" >&2
    echo "Usage: $0 <app_path> <db_file_path>"
    echo "Example: $0 /app/pocket-id /app/data/pocket-id.db"
    exit 1
fi

APP_PATH=$(dirname ${APP})
DB_PATH=$(dirname ${DB_FILE})

export APP_NAME=$(basename ${APP})
export DB_FILE

# ensure running from APP_PATH
cd ${APP_PATH}

# running user
PUID=${PUID:-1000}
PGID=${PGID:-1000}

if [ ! -d "${DB_PATH}" ]; then
    echo "INFO: Creating database directory ${DB_PATH}..."
    mkdir -p "${DB_PATH}"
fi

echo "INFO: Ensure correct ownership of database directory..."
find "${DB_PATH}" \( ! -group "${PGID}" -o ! -user "${PUID}" \) -exec chown "${PUID}:${PGID}" {} +

echo "INFO: Attempting to restore database if missing..."
su-exec "$PUID:$PGID" litestream restore -if-db-not-exists -if-replica-exists ${DB_FILE}

echo "INFO: Starting application using Litestream..."
exec su-exec "$PUID:$PGID" litestream replicate -exec ${APP}
