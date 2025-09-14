FROM debian:bookworm

RUN apt update && apt install -y php8.2-fpm php8.2-mysql curl mariadb-client php8.2-redis

COPY ./tools/script.sh /
RUN chmod +x /script.sh

EXPOSE 9000

ENTRYPOINT ["/script.sh"]