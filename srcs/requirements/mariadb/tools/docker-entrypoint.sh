#!/bin/bash
set -e

# Fix permissions in case they were changed by volume mounts
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# Start MariaDB temporarily for setup as mysql user
su -s /bin/bash mysql -c "mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock &"

# Wait until ready
until mariadb -u root -e "SELECT 1;" &>/dev/null; do sleep 1; done

# Setup database and user
mariadb -u root -e "
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USERNAME}'@'%' IDENTIFIED BY '${MYSQL_USERPASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USERNAME}'@'%';
FLUSH PRIVILEGES;"

# Stop temporary server
mysqladmin shutdown -u root

# Start real server as mysql user
exec su -s /bin/bash mysql -c "mysqld --bind-address=0.0.0.0 --port=3306"
