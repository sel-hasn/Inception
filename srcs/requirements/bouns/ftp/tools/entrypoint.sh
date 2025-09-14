#!/bin/bash

set -e

useradd -m -d /var/www/html -s /bin/bash "$FTP_USER"
echo "$FTP_USER:$FTP_PASS" | chpasswd

exec vsftpd /etc/vsftpd.conf