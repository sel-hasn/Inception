FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx && \
    rm -rf /var/lib/apt/lists/*

COPY ./tools/nginx.conf /etc/nginx/nginx.conf

COPY ./tools/website /var/www/website

EXPOSE 4444

CMD ["nginx", "-g", "daemon off;"]
