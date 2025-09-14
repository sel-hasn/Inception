FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y vsftpd && \
    mkdir -p /var/run/vsftpd/empty

COPY ./tools/vsftpd.conf /etc/vsftpd.conf
COPY ./tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 21
EXPOSE 30000-30009

ENTRYPOINT ["/entrypoint.sh"]