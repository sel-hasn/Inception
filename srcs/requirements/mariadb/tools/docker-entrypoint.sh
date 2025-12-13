#!/bin/bash
set -e

service mariadb start

sleep 5

mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS \`$MYSQL_USERNAME\`@'%' IDENTIFIED BY '$MYSQL_USERPASS';"

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO \`$MYSQL_USERNAME\`@'%';"

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

service mariadb stop

exec mysqld_safe --bind-address=0.0.0.0 --port=3306
