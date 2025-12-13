#!/bin/bash

openssl req -x509 -nodes -days 300 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/CN=$DOMAIN_NAME"

exec nginx -g "daemon off;"