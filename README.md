# Inception Project

## Docker Overview

Docker is a platform for developing, shipping, and running applications inside lightweight containers. Here are the key concepts:

- **Docker Image**: A read-only template with instructions for creating a container. Images are built from Dockerfiles and can be shared via registries.
- **Docker Container**: A running instance of an image. Containers are isolated, portable, and reproducible environments for your applications.
- **Docker Compose**: A tool for defining and running multi-container Docker applications using a YAML file (`docker-compose.yml`). It manages service dependencies and orchestration.
- **Docker Volume**: Persistent storage for containers. Volumes allow data to survive container restarts and are used for databases, uploads, etc.
- **Docker Network**: Virtual networks that connect containers. Networks enable communication between services and can isolate traffic.

## Project Services

This project includes the following services:

- **WordPress**: A PHP-based content management system for building websites and blogs.
- **MariaDB**: An open-source relational database, used by WordPress to store data.
- **Nginx**: A web server that serves WordPress and static content over HTTPS.
- **Redis**: An in-memory key-value store, used for caching in WordPress.
- **FTP**: Provides file transfer access to the WordPress files.
- **Adminer**: A lightweight database management tool for MariaDB.
- **cAdvisor**: Monitors container resource usage and performance.
- **Website**: A static website served by Nginx (bonus service).

## How Services Work Together

- **WordPress** connects to **MariaDB** for its database and to **Redis** for caching.
- **Nginx** serves WordPress and the static website, acting as a reverse proxy.
- **FTP** allows file uploads to the WordPress directory.
- **Adminer** provides a web interface to manage the MariaDB database.
- **cAdvisor** monitors all running containers.
- All services are connected via a custom Docker network (`inception`).
- Persistent data is stored in Docker volumes (`wordpress_volume`, `mariadb_volume`) located in `/home/sel-hasn/data/` on the host machine.

## Detailed File-by-File Explanation

Below is a comprehensive explanation of every file in the project, with each command and configuration line explained:

### .env
```bash
# Database Configuration
MYSQL_DATABASE=wordpress         # Name of the MariaDB database for WordPress
MYSQL_USERNAME=wpuser            # Username for WordPress to access MariaDB
MYSQL_USERPASS=************        # Password for the WordPress database user
MYSQL_ROOT_PASSWORD=************ # Root password for MariaDB (not always used)

# WordPress Configuration
DOMAIN_NAME=sel-hasn.42.fr       # The domain name for your WordPress site
WP_TITLE=My WordPress Site       # The title of your WordPress site
WP_ROOTNAME=admin                # Username for the WordPress admin account
WP_ROOTPASS=************        # Password for the WordPress admin account
WP_ROOTEMAIL=admin@sel-hasn.42.fr# Email for the WordPress admin account
WP_USERNAME=editor               # Username for a secondary WordPress user
WP_USERPASS=************       # Password for the secondary WordPress user
WP_USEREMAIL=editor@sel-hasn.42.fr# Email for the secondary WordPress user
WP_USERROLE=editor               # Role for the secondary WordPress user (e.g., editor)

# Redis Configuration
REDIS_HOST=redis                 # Hostname for the Redis service (used for caching)
REDIS_PORT=6379                  # Port for the Redis service

# FTP Configuration
FTP_USER=ftpuser                 # Username for FTP access
FTP_PASS=************             # Password for FTP access
```

### docker-compose.yml
```yaml
services:                       # Defines all the containers/services in the application

  mariadb:                     # MariaDB database service
    build: ./requirements/mariadb/      # Build image from Dockerfile in this directory
    container_name: mariadb             # Name of the container
    restart: always                     # Always restart if stopped
    env_file: .env                      # Load environment variables from .env
    volumes:                            # Mount persistent storage
      - mariadb_volume:/var/lib/mysql   # Use mariadb_volume for DB data
    networks:
      - inception                       # Connect to inception network

  wordpress:                   # WordPress application service
    build: ./requirements/wordpress/
    container_name: wordpress
    restart: always
    env_file: .env
    volumes:
      - wordpress_volume:/var/www/html  # Use wordpress_volume for WP files
    depends_on:
      - mariadb                        # Start after mariadb is ready
    networks:
      - inception

  nginx:                      # Nginx web server service
    build: ./requirements/nginx/
    container_name: nginx
    restart: always
    env_file: .env
    volumes:
      - wordpress_volume:/var/www/html  # Serve WP files
    depends_on:
      - wordpress                      # Start after WordPress
    ports:
      - "8443:443"                     # Map host port 8443 to container port 443 (HTTPS)
    networks:
      - inception

  redis:                      # Redis caching service
    build: ./requirements/bouns/redis/
    container_name: redis
    restart: always
    env_file: .env
    depends_on:
      - wordpress
    networks:
      - inception

  website:                    # Static website service (bonus)
    build: ./requirements/bouns/website/
    container_name: website
    restart: always
    ports:
      - "4444:4444"                     # Map host port 4444 to container port 4444
    networks:
      - inception

  adminer:                    # Adminer DB management tool
    build: ./requirements/bouns/adminer/
    container_name: adminer
    restart: always
    depends_on:
      - mariadb
    ports:
      - "8888:8080"                     # Map host port 8888 to container port 8080
    networks:
      - inception

  cadvisor:                   # cAdvisor container monitoring
    build: ./requirements/bouns/cadvisor/
    container_name: cadvisor
    restart: always
    ports:
      - "7777:8080"                     # Map host port 7777 to container port 8080
    networks:
      - inception
    volumes:                            # Mount system directories for monitoring
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro

  ftp:                        # FTP file transfer service
    build: ./requirements/bouns/ftp/
    container_name: ftp
    restart: always
    env_file: .env
    ports:
      - "2121:21"                        # FTP control port
      - "30000-30009:30000-30009"        # FTP passive data ports
    volumes:
      - wordpress_volume:/var/www/html   # FTP access to WP files
    networks:
      - inception

volumes:                      # Define persistent storage volumes
  wordpress_volume:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/sel-hasn/data/wordpress  # Bind to host directory

  mariadb_volume:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/sel-hasn/data/mariadb    # Bind to host directory

networks:                     # Define custom Docker network
  inception:
    driver: bridge                        # Use bridge networking
```

## Dockerfiles Explained

### requirements/wordpress/Dockerfile
```dockerfile
FROM debian:bookworm                   # Use Debian Bookworm as base image
RUN apt update && apt install -y php8.2-fpm php8.2-mysql curl mariadb-client php8.2-redis
                                       # Install PHP-FPM, MySQL extension, curl, MariaDB client, Redis extension
COPY ./tools/script.sh /               # Copy entrypoint script to root
RUN chmod +x /script.sh                # Make script executable
EXPOSE 9000                            # Expose PHP-FPM port
ENTRYPOINT ["/script.sh"]              # Run script.sh as entrypoint
```

### requirements/mariadb/Dockerfile
```dockerfile
FROM debian:bookworm                   # Use Debian Bookworm as base image
COPY ./tools/docker-entrypoint.sh /docker-entrypoint.sh
                                       # Copy MariaDB entrypoint script
RUN apt-get update && apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
    chmod +x /docker-entrypoint.sh      # Install MariaDB, clean cache, set permissions, make script executable
EXPOSE 3306                            # Expose MariaDB port
ENTRYPOINT ["/docker-entrypoint.sh"]   # Run entrypoint script
```

### requirements/nginx/Dockerfile
```dockerfile
FROM debian:bookworm                   # Use Debian Bookworm as base image
RUN apt update && apt install -y nginx openssl
                                       # Install Nginx and OpenSSL
RUN mkdir -p /etc/nginx/ssl            # Create directory for SSL certs
RUN openssl req -x509 -nodes -days 300 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=MO/ST=KH/O=42/OU=42/CN=sel-hasn.42.fr"
                                       # Generate self-signed SSL certificate
RUN rm -f /etc/nginx/nginx.conf        # Remove default Nginx config
COPY ./tools/nginx.conf /etc/nginx/nginx.conf
                                       # Copy custom Nginx config
EXPOSE 443                             # Expose HTTPS port
CMD ["nginx", "-g", "daemon off;"]     # Run Nginx in foreground
```

### requirements/bouns/ftp/Dockerfile
```dockerfile
FROM debian:bookworm                   # Use Debian Bookworm as base image
RUN apt-get update && \
    apt-get install -y vsftpd && \
    mkdir -p /var/run/vsftpd/empty     # Install vsftpd and create required directory
COPY ./tools/vsftpd.conf /etc/vsftpd.conf
                                       # Copy FTP server config
COPY ./tools/entrypoint.sh /entrypoint.sh
                                       # Copy entrypoint script
RUN chmod +x /entrypoint.sh            # Make script executable
EXPOSE 21                              # Expose FTP control port
EXPOSE 30000-30009                     # Expose FTP passive data ports
ENTRYPOINT ["/entrypoint.sh"]          # Run entrypoint script
```

### requirements/bouns/adminer/Dockerfile
```dockerfile
FROM debian:bookworm                   # Use Debian Bookworm as base image
RUN apt-get update && \
    apt-get install -y php8.2 php8.2-mysql wget unzip && \
    mkdir -p /var/www/adminer && \
    wget -O /var/www/adminer/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php && \
    rm -rf /var/lib/apt/lists/*
                                       # Install PHP, MySQL extension, wget, unzip; download Adminer; clean cache
WORKDIR /var/www/adminer               # Set working directory
EXPOSE 8080                            # Expose Adminer web port
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
                                       # Run PHP built-in server for Adminer
```

### requirements/bouns/cadvisor/Dockerfile
```dockerfile
FROM debian:bookworm                   # Use Debian Bookworm as base image
RUN apt-get update && \
    apt-get install -y wget ca-certificates && \
    wget https://github.com/google/cadvisor/releases/download/v0.49.1/cadvisor-v0.49.1-linux-amd64 -O /usr/local/bin/cadvisor && \
    chmod +x /usr/local/bin/cadvisor && \
    rm -rf /var/lib/apt/lists/*
                                       # Install wget, ca-certificates; download cAdvisor binary; make executable; clean cache
EXPOSE 8080                            # Expose cAdvisor web port
CMD ["/usr/local/bin/cadvisor", "--logtostderr"]
                                       # Run cAdvisor with logging to stderr
```

### requirements/bouns/website/Dockerfile
```dockerfile
FROM debian:bookworm                   # Use Debian Bookworm as base image
RUN apt-get update && apt-get install -y \
    nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
                                       # Install Nginx, clean cache
COPY ./tools/nginx.conf /etc/nginx/nginx.conf
                                       # Copy custom Nginx config
COPY ./tools/website /var/www/website  # Copy website files
EXPOSE 4444                            # Expose website port
CMD ["nginx", "-g", "daemon off;"]     # Run Nginx in foreground
```

### requirements/bouns/redis/Dockerfile
```dockerfile
FROM debian:bookworm                   # Use Debian Bookworm as base image
RUN apt update -y && apt upgrade -y && apt install -y redis-server
                                       # Install Redis server
CMD ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "no"]
                                       # Run Redis server, bind to all interfaces, disable protected mode
```

## Scripts and Configuration Files Explained

### requirements/wordpress/tools/script.sh
```bash
#!/bin/bash                     # Use bash interpreter
set -e                          # Exit on any error
cd /var/www/html               # Change to WordPress directory

# ---- WP-CLI ----
command -v wp >/dev/null 2>&1 || {
  curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp; }
                               # Download and install WP-CLI if not present

chown -R www-data:www-data .   # Set ownership for web server

# ---- Wait DB ----
until mysqladmin ping -h mariadb -u"$MYSQL_USERNAME" -p"$MYSQL_USERPASS" --silent; do sleep 2; done
                               # Wait until MariaDB is ready

# ---- Core / Config ----
[ -f wp-includes/version.php ] || wp core download --allow-root
                               # Download WordPress core if not present
[ -f wp-config.php ] || wp config create \
  --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USERNAME" \
  --dbpass="$MYSQL_USERPASS" --dbhost=mariadb --allow-root
                               # Create wp-config.php if not present

# ---- Install ----
wp core is-installed --allow-root || wp core install \
  --url="$DOMAIN_NAME" --title="$WP_TITLE" \
  --admin_user="$WP_ROOTNAME" --admin_password="$WP_ROOTPASS" \
  --admin_email="$WP_ROOTEMAIL" --skip-email --allow-root
                               # Install WordPress if not installed

# ---- Extra User ----
if [ -n "$WP_USERNAME" ] && ! wp user get "$WP_USERNAME" --allow-root >/dev/null 2>&1; then
  wp user create "$WP_USERNAME" "$WP_USEREMAIL" --user_pass="$WP_USERPASS" \
    --role="$WP_USERROLE" --allow-root
fi                             # Create additional user if specified and not exists

# ---- Redis ----
wp plugin is-installed redis-cache --allow-root || wp plugin install redis-cache --activate --allow-root
wp plugin is-active redis-cache --allow-root || wp plugin activate redis-cache --allow-root
wp config set WP_REDIS_HOST "$REDIS_HOST" --type=constant --allow-root --quiet || true
wp config set WP_REDIS_PORT "$REDIS_PORT" --type=constant --allow-root --quiet || true
wp redis enable --allow-root || true
                               # Install, activate, and configure Redis cache plugin

# ---- PHP-FPM ----
mkdir -p /run/php              # Create PHP runtime directory
sed -i 's/^listen = .*/listen = 9000/' /etc/php/8.2/fpm/pool.d/www.conf
                               # Configure PHP-FPM to listen on port 9000
exec php-fpm8.2 -F            # Start PHP-FPM in foreground
```

### requirements/mariadb/tools/docker-entrypoint.sh
```bash
#!/bin/bash                    # Use bash interpreter
set -e                         # Exit on any error

# Fix permissions in case they were changed by volume mounts
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# Start MariaDB temporarily for setup as mysql user
su -s /bin/bash mysql -c "mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock &"

# Wait until ready
until mariadb -u root -e "SELECT 1;" &>/dev/null; do sleep 1; done

# Setup database and user
mariadb -u root -e "
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USERNAME}'@'%' IDENTIFIED BY '${MYSQL_USERPASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USERNAME}'@'%';
FLUSH PRIVILEGES;"             # Create database and user with privileges

# Stop temporary server
mysqladmin shutdown -u root

# Start real server as mysql user
exec su -s /bin/bash mysql -c "mysqld --bind-address=0.0.0.0 --port=3306"
```

### requirements/bouns/ftp/tools/entrypoint.sh
```bash
#!/bin/bash                    # Use bash interpreter
set -e                         # Exit on any error

# Only add user if not present
id "$FTP_USER" &>/dev/null || useradd -m -d /var/www/html -s /bin/bash "$FTP_USER"
echo "$FTP_USER:$FTP_PASS" | chpasswd
                               # Create FTP user and set password

exec vsftpd /etc/vsftpd.conf   # Start vsftpd with config
```

### requirements/nginx/tools/nginx.conf
```nginx
worker_processes 1;            # Use 1 worker process

events {
    worker_connections 1024;   # Max 1024 connections per worker
}

http {
    include mime.types;        # Include MIME type definitions
    server {
        listen 443 ssl;        # Listen on port 443 with SSL
        root /var/www/html;    # Document root for WordPress
        server_name sel-hasn.42.fr;  # Server name
        index index.php;       # Default index file

        ssl_certificate /etc/nginx/ssl/nginx.crt;     # SSL certificate path
        ssl_certificate_key /etc/nginx/ssl/nginx.key; # SSL key path
        ssl_protocols TLSv1.3; # Use TLS 1.3 only

        location ~ \.php$ {    # Handle PHP files
            include fastcgi_params;
            fastcgi_pass wordpress:9000;  # Forward to WordPress container
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
}
```

### requirements/bouns/ftp/tools/vsftpd.conf
```conf
listen=YES                     # Enable standalone mode
local_enable=YES               # Allow local users to log in
write_enable=YES               # Allow write operations
chroot_local_user=YES          # Chroot users to their home directory
allow_writeable_chroot=YES     # Allow writable chroot
secure_chroot_dir=/var/run/vsftpd/empty  # Secure chroot directory
local_root=/var/www/html       # Set local root to WordPress directory
pasv_enable=YES                # Enable passive mode
pasv_min_port=30000            # Minimum passive port
pasv_max_port=30009            # Maximum passive port
```

### requirements/bouns/website/tools/nginx.conf
```nginx
events {}                      # Empty events block

http {
    include       /etc/nginx/mime.types;  # Include MIME types

    server {
        listen 4444;           # Listen on port 4444
        server_name localhost; # Server name
        root /var/www/website; # Document root
        index index.html;      # Default index file

        location / {
            try_files $uri $uri/ =404;  # Try files, return 404 if not found
        }
    }
}
```

### requirements/bouns/website/tools/website/index.html
```html
<!DOCTYPE html>                <!-- HTML5 doctype -->
<html lang="en">               <!-- HTML element with English language -->
<head>
  <meta charset="UTF-8">       <!-- Character encoding -->
  <title>Inception Static Site</title>  <!-- Page title -->
  <link rel="stylesheet" href="style.css">  <!-- Link to CSS file -->
</head>
<body>
  <h1>Hello from Inception 🚀</h1>        <!-- Main heading -->
  <p>This is a simple static website served by <strong>Nginx</strong>.</p>  <!-- Paragraph -->
</body>
</html>
```

### requirements/bouns/website/tools/website/stayle.css
```css
body {
  font-family: Arial, sans-serif;  /* Set font family */
  text-align: center;              /* Center text */
  background: #fafafa;             /* Light background color */
  color: #333;                     /* Dark text color */
  padding: 50px;                   /* Add padding */
}
h1 {
  color: #007acc;                  /* Blue color for heading */
}
```

## Getting Started

**Important**: Before running the project, ensure the data directories exist:

```bash
mkdir -p /home/sel-hasn/data/wordpress
mkdir -p /home/sel-hasn/data/mariadb
```

To build and run the project:

```zsh
make up   # or docker compose up --build -d
```

To stop all services:

```zsh
make down # or docker compose down
```

To view logs:

```zsh
docker compose logs -f
```

To access a service shell (example: WordPress):

```zsh
docker compose exec wordpress bash
```

---

For more details, see each service’s Dockerfile and entrypoint script.
