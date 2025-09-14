#!/bin/bash

cd /var/www/html

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
chmod -R 755 /var/www/html
chown -R www-data:www-data /var/www/html
mv wp-cli.phar /usr/local/bin/wp

until mysqladmin ping -h mariadb -u"${MYSQL_USERNAME}" -p"${MYSQL_USERPASS}" --silent; do
  sleep 2
done

wp core download --allow-root
wp config create \
    --dbname=${MYSQL_DATABASE} \
    --dbuser=${MYSQL_USERNAME} \
    --dbpass=${MYSQL_USERPASS} \
    --dbhost=mariadb --allow-root

wp core install \
    --url=${DOMAIN_NAME} \
    --title=${WP_TITLE} \
    --admin_user=${WP_ROOTNAME} \
    --admin_password=${WP_ROOTPASS} \
    --admin_email=${WP_ROOTEMAIL} --allow-root

wp user create ${WP_USERNAME} ${WP_USEREMAIL} \
    --user_pass=${WP_USERPASS} \
    --role=${WP_USERROLE} --allow-root

wp plugin install redis-cache --activate --allow-root
wp config set WP_REDIS_HOST "${REDIS_HOST}" --type=constant --allow-root
wp config set WP_REDIS_PORT "${REDIS_PORT}" --type=constant --allow-root
wp redis enable --allow-root

mkdir -p /run/php

sed -i 's/\/run\/php\/php8.2-fpm.sock/9000/' /etc/php/8.2/fpm/pool.d/www.conf

exec /usr/sbin/php-fpm8.2 -F