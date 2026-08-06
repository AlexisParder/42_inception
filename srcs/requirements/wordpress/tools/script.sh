#!/bin/sh

WP_PASS=$(cat /run/secrets/wp_admin_password)
WP_PASS2=$(cat /run/secrets/wp_user_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -f wp-config.php ]; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	./wp-cli.phar core download --allow-root
	./wp-cli.phar config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --dbhost=mariadb --allow-root
	./wp-cli.phar core install --url=$DOMAIN_NAME --title=inception --admin_user=$WP_USER --admin_password=$WP_PASS --admin_email=$WP_MAIL --allow-root
	./wp-cli.phar user create $WP_USER2 $WP_MAIL2 --role=author --user_pass=$WP_PASS2 --allow-root
	./wp-cli.phar user set-role 2 editor --allow-root
	./wp-cli.phar theme install astra --activate --allow-root

	./wp-cli.phar plugin install redis-cache --activate --allow-root
	./wp-cli.phar config set WP_REDIS_HOST redis --allow-root
	./wp-cli.phar config set WP_REDIS_PORT 6379 --raw --allow-root
	./wp-cli.phar redis enable --allow-root

	chown -R :www-data /var/www/html
	chmod -R g+w /var/www/html
fi

exec "$@" 