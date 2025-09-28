FROM debian:bookworm

COPY ./tools/docker-entrypoint.sh /docker-entrypoint.sh

RUN apt-get update && apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
    chmod +x /docker-entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/docker-entrypoint.sh"]