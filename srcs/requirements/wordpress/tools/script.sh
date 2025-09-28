#!/bin/bash
set -e
cd /var/www/html

# ---- WP-CLI ----
command -v wp >/dev/null 2>&1 || {
    curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp; }

chown -R www-data:www-data .

# ---- Wait DB ----
until mysqladmin ping -h mariadb -u"$MYSQL_USERNAME" -p"$MYSQL_USERPASS" --silent; do sleep 2; done

# ---- Core / Config ----

[ -f wp-includes/version.php ] || wp core download --allow-root
[ -f wp-config.php ] || wp config create \
    --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USERNAME" \
    --dbpass="$MYSQL_USERPASS" --dbhost=mariadb --allow-root

# ---- Install ----
wp core is-installed --allow-root || wp core install \
    --url="$DOMAIN_NAME" --title="$WP_TITLE" \
    --admin_user="$WP_ROOTNAME" --admin_password="$WP_ROOTPASS" \
    --admin_email="$WP_ROOTEMAIL" --skip-email --allow-root

# ---- Extra User ----
if [ -n "$WP_USERNAME" ] && ! wp user get "$WP_USERNAME" --allow-root >/dev/null 2>&1; then
    wp user create "$WP_USERNAME" "$WP_USEREMAIL" --user_pass="$WP_USERPASS" \
        --role="$WP_USERROLE" --allow-root
fi

# ---- Redis ----
wp plugin is-installed redis-cache --allow-root || wp plugin install redis-cache --activate --allow-root
wp plugin is-active redis-cache --allow-root || wp plugin activate redis-cache --allow-root
wp config set WP_REDIS_HOST "$REDIS_HOST" --type=constant --allow-root --quiet || true
wp config set WP_REDIS_PORT "$REDIS_PORT" --type=constant --allow-root --quiet || true
wp redis enable --allow-root || true

# ---- PHP-FPM ----
mkdir -p /run/php
sed -i 's/^listen = .*/listen = 9000/' /etc/php/8.2/fpm/pool.d/www.conf
exec php-fpm8.2 -F
