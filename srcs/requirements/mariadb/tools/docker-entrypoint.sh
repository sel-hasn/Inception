#!/bin/bash
set -e

# 1. Start MariaDB (uses default config, listens on localhost only)
service mariadb start

# Wait for startup
sleep 5

# 2. Smart Configuration Check
if mysql -u root -e "status" > /dev/null 2>&1; then
    echo "Fresh installation detected. Configuring MariaDB..."

    mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
    mariadb -u root -e "CREATE USER IF NOT EXISTS \`$MYSQL_USERNAME\`@'%' IDENTIFIED BY '$MYSQL_USERPASS';"
    mariadb -u root -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO \`$MYSQL_USERNAME\`@'%';"
    mariadb -u root -e "FLUSH PRIVILEGES;"
    
    # Lock the root user
    mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
    
    echo "MariaDB configuration finished."
else
    echo "Database is already configured. Skipping initialization."
fi

# 3. Shutdown temporary service
mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

# 4. Start Final Process with Command Line Flags (No Config File Needed)
# --bind-address=0.0.0.0 : Allow connections from WordPress
# --datadir : Explicitly tell it where the data volume is
exec mysqld_safe --port=3306 --bind-address=0.0.0.0