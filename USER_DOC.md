# User Documentation

## Services Overview
This project deploys a small web infrastructure made of these services:
* **Website**: A WordPress site served over HTTPS.
* **Database**: MariaDB for WordPress persistence.
* **Administration**: Adminer (database UI) and cAdvisor (resource monitoring).
* **File transfer**: FTP access to WordPress files (bonus).
* **Cache**: Redis to speed up WordPress (bonus).

## 🧰 Prerequisites
Before using the stack, make sure the initial setup is complete.

* **Hosts file:** Configure `/etc/hosts` so your `<login>.42.fr` domain resolves locally (see `DEV_DOC.md`).
* **Environment variables:** Create `srcs/.env` and fill in the credentials (see `DEV_DOC.md`).

## How to Start and Stop
Run the following commands from the repository root:

* **Start Project:**
    ```bash
    make up
    ```
    *Builds the images (if needed) and starts the containers in the background.*

* **Stop Project:**
    ```bash
    make down
    ```
    *Stops and removes the running containers.*

## Accessing the Services
After `make up`, you can reach the services using a browser (or an FTP client).
*Note: your browser may warn about the certificate depending on how TLS is set up.*

| Service | URL / Port | Description |
| :--- | :--- | :--- |
| **WordPress** | `https://<login>.42.fr` | Main website (HTTPS only) |
| **Adminer** | `https://adminer.<login>.42.fr` | Database management tool |
| **Static Site** | `https://static.<login>.42.fr` | Bonus static HTML page |
| **cAdvisor** | `https://cadvisor.<login>.42.fr` | Container monitoring |
| **FTP Server** | `lftp -u <user>,<pass> 127.0.0.1` | File Transfer (CLI) |

*(Replace `<login>` with your 42 username. If you didn’t enable bonus services, some URLs won’t exist.)*

## Locate and Manage Credentials
There are no hardcoded default passwords in the repository. Credentials are read from your local environment file.

**File Location:** `srcs/.env`

Open `srcs/.env` and locate the variables used by:
* **WordPress Admin:** Variables `WP_ROOTNAME` and `WP_ROOTPASS`.
* **WordPress User:** Variables `WP_USERNAME` and `WP_USERPASS`.
* **Database:** Variables `MYSQL_USERNAME` and `MYSQL_USERPASS`.
* **FTP:** Variables `FTP_USER` and `FTP_PASS`.

## Checking Status
To confirm containers are running and see exposed ports:
```bash
cd srcs && docker compose ps