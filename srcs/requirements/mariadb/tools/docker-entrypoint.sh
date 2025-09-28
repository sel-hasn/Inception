#!/bin/bash
set -e

# Start MariaDB service
service mariadb start

# Wait for MariaDB to be ready
sleep 5

# Set root password
mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"

# Create database
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"

# Create user
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS \`$MYSQL_USERNAME\`@'%' IDENTIFIED BY '$MYSQL_USERPASS';"

# Grant privileges (fix: use $MYSQL_USERNAME, not hardcoded 'mhimi')
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO \`$MYSQL_USERNAME\`@'%';"

# Flush privileges
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

# Stop service
service mariadb stop

# Start daemon
exec mysqld_safe --bind-address=0.0.0.0