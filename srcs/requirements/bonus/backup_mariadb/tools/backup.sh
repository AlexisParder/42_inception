#!/bin/bash
source /etc/environment

DB_PASS=$(cat /run/secrets/db_password)

mysqldump -h mariadb -u $DB_USER -p${DB_PASS} $DB_NAME > /backups/backup_$(date +%Y%m%d_%H%M%S).sql

find /backups -name "*.sql" -mtime +1 -delete