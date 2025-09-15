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
- Persistent data is stored in Docker volumes (`wordpress_volume`, `mariadb_volume`).

## File-by-File Explanation

Below is a detailed explanation of every file in the project, letter by letter:

### .env
Environment variables for all services (database credentials, WordPress settings, FTP user/pass, Redis config).

### docker-compose.yml
Defines all services, their build contexts, environment files, volumes, networks, and dependencies.

### requirements/bouns/adminer/Dockerfile
Builds the Adminer service (PHP-based DB admin tool).

### requirements/bouns/cadvisor/Dockerfile
Builds the cAdvisor service for container monitoring.

### requirements/bouns/ftp/Dockerfile
Builds the FTP service for file transfer.

### requirements/bouns/ftp/tools/entrypoint.sh
Entrypoint script for FTP: creates user, sets password, starts vsftpd.

### requirements/bouns/ftp/tools/vsftpd.conf
Configuration file for the vsftpd FTP server.

### requirements/bouns/website/Dockerfile
Builds the static website service.

### requirements/bouns/website/tools/nginx.conf
Nginx configuration for serving the static website.

### requirements/bouns/website/tools/website/index.html
Homepage for the static website.

### requirements/bouns/website/tools/website/stayle.css
CSS styles for the static website.

### requirements/mariadb/Dockerfile
Builds the MariaDB database service.

### requirements/mariadb/tools/docker-entrypoint.sh
Entrypoint script for MariaDB: initializes database, creates user, starts server.

### requirements/nginx/Dockerfile
Builds the Nginx web server service.

### requirements/nginx/tools/nginx.conf
Nginx configuration for serving WordPress and static content.

### requirements/wordpress/Dockerfile
Builds the WordPress service (PHP-FPM, WP-CLI, Redis extension).

### requirements/wordpress/tools/script.sh
Entrypoint script for WordPress: installs WP-CLI, waits for DB, sets up WordPress, configures Redis, starts PHP-FPM.

---

## Getting Started

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
