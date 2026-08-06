#!/bin/bash

envsubst '${DOMAIN_NAME}' < /etc/nginx/templates/nginx.conf.template > /etc/nginx/conf.d/nginx.conf

if [ ! -f /etc/nginx/ssl/certificate_static.crt ]; then
	openssl req -x509 -nodes -days 365 -out /etc/nginx/ssl/certificate_static.crt -keyout /etc/nginx/ssl/certificate_static.key -subj "/C=FR/ST=NA/L=Angouleme/O=42/OU=42/CN=static.${DOMAIN_NAME}/UID=${LOGIN}"
fi

exec "$@"