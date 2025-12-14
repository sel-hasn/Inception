FROM debian:bookworm

RUN apt update -y && apt install -y redis-server && rm -rf /var/lib/apt/lists/*

EXPOSE 6379

CMD ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "no", "--port", "6379"]