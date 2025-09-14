FROM debian:bookworm

RUN apt update && apt install -y nginx openssl 

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 300 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=MO/ST=KH/O=42/OU=42/CN=eahiri.42.fr"

RUN rm -f /etc/nginx/nginx.conf

COPY ./tools/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]