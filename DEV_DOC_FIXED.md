# Developer Documentation

This document explains how a developer can set up, build, and debug the Inception stack.

## 1) Set up the environment from scratch

### Prerequisites
Install on the host:
- Docker Engine
- Docker Compose (v2)
- GNU Make

#### Install commands (Ubuntu / Debian)

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin make
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

#### Install commands (macOS)

Install Docker Desktop (includes Docker Engine + Docker Compose):
```bash
brew install --cask docker
```

Install GNU Make (if you don’t already have it):
```bash
brew install make
```

After adding your user to the `docker` group on Linux, log out and back in (or restart) for the change to take effect.

### Configuration file: `srcs/.env` (credentials + settings)
Create `srcs/.env` before starting the project. This file contains secrets and should not be committed.

The repository expects the following variable names (same as `srcs/.env`):
- **MariaDB**: `MYSQL_DATABASE`, `MYSQL_USERNAME`, `MYSQL_USERPASS`, `MYSQL_ROOT_PASSWORD`
- **WordPress**:
  - Site: `DOMAIN_NAME`, `WP_TITLE`
  - Admin: `WP_ROOTNAME`, `WP_ROOTPASS`, `WP_ROOTEMAIL`
  - User: `WP_USERNAME`, `WP_USERPASS`, `WP_USEREMAIL`, `WP_USERROLE`
- **Redis** (bonus): `REDIS_HOST`, `REDIS_PORT`
- **FTP** (bonus): `FTP_USER`, `FTP_PASS`

### Hostname resolution (`/etc/hosts`)
The domain is configured by `DOMAIN_NAME` in `srcs/.env` (example: `sel-hasn.42.fr`).
For local testing/evaluation, map it to localhost:

- `127.0.0.1 sel-hasn.42.fr`

Append the line to your hosts file (works on Ubuntu and macOS):

```bash
echo "127.0.0.1 sel-hasn.42.fr" | sudo tee -a /etc/hosts > /dev/null
```

If you use additional hostnames/subdomains in your NGINX config for bonus services, add them as well.

## 2) Build and launch

### Using the Makefile (recommended)
From the repository root:
- `make up`: creates `/home/${USER}/data/{mariadb,wordpress}` then starts the stack (`cd srcs && docker compose up -d`)
- `make build`: rebuild images and start containers
- `make down`: stop and remove containers
- `make clean`: stop containers and prune Docker resources
- `make fclean`: **destructive reset** (also removes `/home/${USER}/data`)

### Using Docker Compose directly
From `srcs/`:
- `docker compose up -d`
- `docker compose up -d --build`
- `docker compose down`

## 3) Manage containers and volumes

Useful commands:
- Status: `cd srcs && docker compose ps`
- Logs: `cd srcs && docker compose logs -f --tail=200`
- Shell: `docker exec -it <container_name> sh`
- Inspect network: `docker network inspect inception`

## 4) Data persistence

The stack uses **bind mounts** defined in `srcs/docker-compose.yml` under `driver_opts`.

Persisted paths on the host:
- MariaDB: `/home/${USER}/data/mariadb`
- WordPress: `/home/${USER}/data/wordpress`

Data remains even after `docker compose down`.

To remove persisted data and start fresh (⚠️ deletes database + WordPress files):
- `make fclean`

## 5) Evaluation talking points
Be ready to explain:
- how Docker and Docker Compose work together (Compose orchestrates multiple services/containers)
- the difference between using an image alone vs via Compose (networks, volumes, dependencies)
- why Docker is beneficial compared to VMs (lighter isolation, faster startup)
- why the directory structure is pertinent (`srcs/docker-compose.yml` + per-service Dockerfiles in `srcs/requirements/`)
