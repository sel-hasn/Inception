#!/bin/bash

set -e

# Only add user if not present
id "$FTP_USER" &>/dev/null || useradd -m -d /var/www/html -s /bin/bash "$FTP_USER"
echo "$FTP_USER:$FTP_PASS" | chpasswd

exec vsftpd /etc/vsftpd.conf