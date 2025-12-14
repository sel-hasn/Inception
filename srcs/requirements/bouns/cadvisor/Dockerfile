FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y wget ca-certificates && \
    wget https://github.com/google/cadvisor/releases/download/v0.49.1/cadvisor-v0.49.1-linux-amd64 -O /usr/local/bin/cadvisor && \
    chmod +x /usr/local/bin/cadvisor && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8080

CMD ["/usr/local/bin/cadvisor", "--logtostderr", "--port=8080"]