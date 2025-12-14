#!/bin/bash

# THIS IS THE MAGIC LINE
# It finds "MY_DOMAIN_NAME" in the config and replaces it 
# with the actual value from your .env (e.g., salah-eddin.42.fr)
sed -i "s/MY_DOMAIN_NAME/$DOMAIN_NAME/g" /etc/nginx/nginx.conf

# Generate the SSL certificate using the same domain
openssl req -x509 -nodes -days 300 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/CN=$DOMAIN_NAME"

exec nginx -g "daemon off;"