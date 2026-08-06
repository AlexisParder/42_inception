#!/bin/bash

export DB_PASSWORD=$(cat /run/secrets/db_password)
export DB_ADMIN_PASS=$(cat /run/secrets/db_root_password)

if [ -f /entrypoint-initdb.d/init.sql.template ]; then
  envsubst < /entrypoint-initdb.d/init.sql.template > /etc/mysql/init.sql
  rm /entrypoint-initdb.d/init.sql.template
fi

exec "$@"