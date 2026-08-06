#!/bin/bash

FTP_PASS=$(cat /run/secrets/ftp_password)

if ! id $FTP_USER > /dev/null 2>&1; then
	adduser $FTP_USER --disabled-password --home /var/www/html --gecos "" --ingroup www-data
	echo "$FTP_USER:$FTP_PASS" | chpasswd
fi

envsubst '${HOST_IP}' < /etc/vsftpd/templates/vsftpd.conf.template > /etc/vsftpd.conf
exec "$@"