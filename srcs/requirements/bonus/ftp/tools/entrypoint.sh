#!/bin/bash
set -e

# Only create the user if it doesn't exist
if ! id "$FTP_USER" &>/dev/null; then
    useradd -m -d /var/www/html -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    
    # Add to www-data group so it can modify WordPress files
    usermod -a -G www-data "$FTP_USER"
fi

# Ensure correct ownership and permissions for the volume
# 775 allows Group (www-data) to write, which is needed for WP + FTP to work together
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

exec vsftpd /etc/vsftpd.conf