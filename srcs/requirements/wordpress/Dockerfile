FROM debian:bookworm

# Install PHP and dependencies
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    php8.2-redis \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 1. Install WP-CLI (Moved from script.sh)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# 2. Configure PHP-FPM
RUN mkdir -p /run/php && \
    sed -i 's/^listen = .*/listen = 9000/' /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/script.sh /
RUN chmod +x /script.sh

EXPOSE 9000

ENTRYPOINT ["/script.sh"]