FROM debian:bookworm

RUN apt update && apt install -y nginx openssl && \
    mkdir -p /etc/nginx/ssl && \
    rm -f /etc/nginx/nginx.conf

COPY ./tools/script.sh /script.sh
COPY ./tools/nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /script.sh

EXPOSE 443

ENTRYPOINT ["/script.sh"]