#!/bin/bash
set -e
cd /var/www/html

# Wait until MariaDB is ready to accept connections
until mariadb-admin ping -h mariadb -u"$MYSQL_USERNAME" -p"$MYSQL_USERPASS" --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done

# ---- Core / Config ----
# Only download/install if wp-config.php doesn't exist
if [ ! -f wp-config.php ]; then
    echo "Installing WordPress..."
    
    # Download Core
    wp core download --allow-root

    # Create Config
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USERNAME" \
        --dbpass="$MYSQL_USERPASS" \
        --dbhost=mariadb \
        --allow-root

    # Install WP
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ROOTNAME" \
        --admin_password="$WP_ROOTPASS" \
        --admin_email="$WP_ROOTEMAIL" \
        --skip-email \
        --allow-root

    # Create Extra User
    wp user create "$WP_USERNAME" "$WP_USEREMAIL" \
        --user_pass="$WP_USERPASS" \
        --allow-root

    # Install Redis Plugin and Configure
    wp plugin install redis-cache --activate --allow-root
    wp config set WP_REDIS_HOST "$REDIS_HOST" --type=constant --allow-root --quiet
    wp config set WP_REDIS_PORT "$REDIS_PORT" --type=constant --allow-root --quiet
    wp redis enable --allow-root
fi

# ---- Permissions ----
# Ensure www-data owns the files (crucial for Nginx/PHP to write)
chown -R www-data:www-data /var/www/html

# ---- Start PHP-FPM ----
# We use exec so the process becomes PID 1 (handling signals correctly)
exec php-fpm8.2 -F