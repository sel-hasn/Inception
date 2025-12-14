#!/bin/bash
set -e

# 1. Start the service (temporary, just to run the init commands)
service mariadb start

# Wait a moment for the socket to be ready (Not a loop, just a safety pause)
sleep 2

# 2. Configure the Database
# Note: Variables updated to match your .env file names
echo "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;" > db_init.sql
echo "CREATE USER IF NOT EXISTS \`${MYSQL_USERNAME}\`@'%' IDENTIFIED BY '${MYSQL_USERPASS}';" >> db_init.sql
echo "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USERNAME}\`@'%';" >> db_init.sql
echo "FLUSH PRIVILEGES;" >> db_init.sql

# 3. Execute the SQL commands
mysql -u root < db_init.sql

# 4. Set Root Password (do this last, otherwise you lose access for the commands above)
# This shuts down the service safely using the password if it was already set, or no password if it wasn't.
# We try to shutdown using the env password; if that fails, we assume no password is set yet.
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown || mysqladmin -u root shutdown

# 5. Start the actual server process in the foreground (PID 1)
exec mysqld_safe
