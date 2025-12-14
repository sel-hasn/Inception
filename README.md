*This project has been created as part of the 42 curriculum by sel-hasn.*

# Inception

## Description
This project is a System Administration exercise focused on practicing **Docker** by building a small, self-contained infrastructure. Multiple services are containerized and wired together with **Docker Compose**, with each component running in its own container.

The infrastructure includes:
- **NGINX**: The entry point with TLSv1.2/1.3.
- **WordPress + PHP-FPM**: The Content Management System.
- **MariaDB**: The database.
- **Redis**: For cache management (Bonus).
- **FTP Server**: For file transfer (Bonus).
- **Adminer**: For database management (Bonus).
- **cAdvisor**: For container monitoring (Bonus).
- **Static Website**: A custom static page (Bonus).

## Instructions

1.  **Prerequisites:**
    - Docker Engine and Docker Compose installed.
    - `make` installed.

2.  **Configuration:**
    - Create your `.env` in `srcs/.env` (template and variables are documented in `DEV_DOC.md`).
    - Add the project domain to your hosts file (documented in `DEV_DOC.md`).

3.  **Execution:**
    Build and start the stack:
    ```bash
    make up
    ```

4.  **Cleaning:**
    Stop the stack and remove volumes (clean slate):
    ```bash
    make fclean
    ```

## Resources

### Docker (Official Docs)
* [Docker overview](https://docs.docker.com/get-started/overview/)
* [What is a container?](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/)
* [Container Images](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-an-image/)
* [Docker Engine](https://docs.docker.com/engine/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Networking](https://docs.docker.com/network/)
* [Docker Volumes](https://docs.docker.com/storage/volumes/)
* [Docker CLI reference](https://docs.docker.com/engine/reference/commandline/cli/)

### Services & Tools
* [NGINX Documentation](https://nginx.org/en/docs/)
* [WordPress](https://wordpress.org/support/)
* [MariaDB Documentation](https://mariadb.com/docs/)
* [Redis Documentation](https://redis.io/docs/latest/)
* [vsftpd (Debian wiki)](https://wiki.debian.org/vsftpd)
* [Adminer](https://www.adminer.org/)
* [cAdvisor](https://github.com/google/cadvisor)
* [WP-CLI](https://wp-cli.org/)

### Guides & Handbooks
* [PHP-FPM (PHP Manual)](https://www.php.net/manual/en/install.fpm.php)
* [The NGINX Handbook (FreeCodeCamp)](https://www.freecodecamp.org/news/the-nginx-handbook)

### AI Usage Declaration
Artificial Intelligence tools were used as development assistance for specific, non-graded tasks.
* **Documentation drafting:** AI helped rephrase and structure `README.md`, `USER_DOC.md`, and `DEV_DOC.md` so the documentation matches the 42 subject expectations (notably Chapters VI and VII).
* **Debugging assistance:** AI helped troubleshoot container connectivity/port publishing and NGINX configuration issues (TLS settings, redirects, and upstream routing).
* **Script improvement:** AI assisted in reviewing and optimizing initialization scripts (WordPress/MariaDB/FTP) to make startup order, retries, and idempotent setup more reliable.

## Project Description & Design Choices

### Why Docker / Docker Compose in this project?
The goal of **Inception** is to build a reproducible multi-service environment where each service runs in its own isolated container (NGINX, WordPress/PHP-FPM, MariaDB, etc.). **Docker Compose** is used to define and run the whole stack (networks, volumes, and service dependencies) from a single configuration.

### Where are the project sources?
The stack is defined and implemented in the `srcs/` folder:
* `srcs/docker-compose.yml`: the Compose file wiring all services together.
* `srcs/requirements/`: Dockerfiles and configuration/scripts for each service.
    * Mandatory: `srcs/requirements/nginx/`, `srcs/requirements/wordpress/`, `srcs/requirements/mariadb/`
    * Bonus (if enabled in your compose): `srcs/requirements/bonus/` (adminer, redis, ftp, cadvisor, website)

### Virtual Machines vs Docker
- **Virtual Machines (VMs)** emulate a full machine. They typically boot a complete OS (including its own kernel), which increases startup time and resource usage.
- **Docker** isolates processes at the OS level. Containers share the host kernel but run with separated namespaces/cgroups.
* **Choice:** Docker fits the goal of reproducible, lightweight services while keeping isolation between components.

### Secrets vs Environment Variables
- **Docker Secrets** are designed for sensitive values, stored and delivered to containers in a controlled way.
- **Environment Variables** (`.env`) are convenient for local setups but can be exposed via logs or inspection.
* **Choice:** Per the subject constraints, this project uses `.env` for simplicity and keeps it out of version control to avoid leaking credentials.

### Docker Network vs Host Network
- **Docker (bridge) network:** Services communicate over an isolated virtual network and discover each other by service name via Docker DNS.
- **Host network:** A container uses the host network namespace directly, reducing isolation and increasing the risk of port conflicts.
- **Choice:** A dedicated bridge network (`inception`) keeps internal traffic private (e.g., WordPress → MariaDB) while only publishing the needed ports to the host.

### Docker Volumes vs Bind Mounts
- **Docker Volumes:** Docker-managed persistent storage, independent of a specific host path.
- **Bind Mounts:** A direct mapping between a host directory and a container path.
* **Choice:** To match the subject’s persistence requirement, this project uses bind mounts under `/home/${USER}/data`.
