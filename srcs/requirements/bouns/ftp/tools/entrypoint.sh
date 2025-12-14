#!/bin/bash

set -e

id "$FTP_USER" &>/dev/null || useradd -m -d /var/www/html "$FTP_USER"
echo "$FTP_USER:$FTP_PASS" | chpasswd

usermod -a -G www-data "$FTP_USER"
chmod -R g+w /var/www/html

exec vsftpd /etc/vsftpd.conf