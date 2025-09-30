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
