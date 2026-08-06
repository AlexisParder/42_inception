# Developer documentation
- [Developer documentation](#developer-documentation)
	- [Setting up the environment from scratch](#setting-up-the-environment-from-scratch)
		- [Prerequisites](#prerequisites)
		- [Configuration](#configuration)
	- [Building and starting the project via Makefile and Docker Compose](#building-and-starting-the-project-via-makefile-and-docker-compose)
	- [Container and volume management commands](#container-and-volume-management-commands)
	- [Data location and persistence](#data-location-and-persistence)
		- [Where the data is actually stored](#where-the-data-is-actually-stored)
		- [How to actually check/explore this data](#how-to-actually-checkexplore-this-data)
		- [What persists, and what does not](#what-persists-and-what-does-not)

## Setting up the environment from scratch

### Prerequisites
- Docker
- Docker Compose
- Debian environment (Linux)

### Configuration
- Configure `.env`:
  - Go to `./srcs/`
  - Create a `.env` file
  - Fill in the file as shown in the example below
	```env
	# Corresponds to your Debian user
	LOGIN=...

	# Database user and name
	DB_USER=...
	DB_NAME=...

	# Full domain, example: <LOGIN>.42.fr
	DOMAIN_NAME=...

	# WordPress Administrator account
	WP_USER=...
	WP_MAIL=...

	# WordPress User account
	WP_USER2=...
	WP_MAIL2=...

	# BONUS FTP: User account for FTP
	FTP_USER=...
	```
	> For the domain to be resolved locally, open the `/etc/hosts` file (with administrator privileges) and add the following lines:
    >- `127.0.0.1 <DOMAIN_NAME>`
    >- `127.0.0.1 static.<DOMAIN_NAME>`
    >- `127.0.0.1 adminer.<DOMAIN_NAME>`

- Configure the `secrets` (this is where the passwords are stored):
  - Create a `secrets` folder at the root of the project (at the same level as `srcs`)
  - Create the files below inside the `secrets` folder
    - `db_password.txt` => password of the database user
    - `db_root_password.txt` => password of the database administrator (`root`)
    - `wp_admin_password.txt` => password of the WordPress administrator (corresponds to `WP_USER` in `.env`)
    - `wp_user_password.txt` => password of the WordPress user (corresponds to `WP_USER2` in `.env`)
    - `ftp_password.txt` => password of the user (corresponds to `FTP_USER` in `.env`) for the FTP bonus
	> Each of these files must contain only the corresponding password, nothing else: no line break, no space, no newline before or after the value.

## Building and starting the project via Makefile and Docker Compose
Once the configuration is complete, open a terminal and go to the root of this folder.
Several commands are available:

- `make` : starts the different services.
  - On the first launch, the folders required for the volumes are created in `/home/<LOGIN>/data/...`, then Docker builds the project's 8 images (`nginx`, `mariadb`, `wordpress`, `redis`, `ftp`, `static_website`, `adminer`, `adminer_nginx`, `backup_mariadb`) from their respective Dockerfiles, creates the `inception` network as well as the named volumes (`mariadb`, `wordpress`, `backup_mariadb`), and starts the containers in the order of their dependencies.
- `make build` : starts the different services.
  - On the first launch, the folders required for the volumes are created in `/home/<LOGIN>/data/...`, then Docker builds the project's 8 images (`nginx`, `mariadb`, `wordpress`, `redis`, `ftp`, `static_website`, `adminer`, `adminer_nginx`, `backup_mariadb`) from their respective Dockerfiles, creates the `inception` network as well as the named volumes (`mariadb`, `wordpress`, `backup_mariadb`), and starts the containers in the order of their dependencies.
  - Rebuilding the images is systematic on every launch (`--build` option), ensuring that any change to a Dockerfile or to a file copied into an image is properly taken into account.
- `make down` : stops the services by running `docker compose down`. `make` will restart everything.
- `make clean` : stops the services (`down`) then removes the `/home/<LOGIN>/data` folder and its content from disk (the `-v` flag present in the command `docker compose -f ./srcs/docker-compose.yml down -v` also removes the Docker volumes, not just the containers).
- `make fclean` : performs a `clean`, then runs `docker system prune -af` to remove all unused Docker images.
- `make re` : equivalent to `make fclean` followed by `make`, i.e. a complete reinstallation of the project from scratch.
> **WARNING**: the `make fclean` command (and therefore also `make re`, which runs it) performs a complete cleanup via `docker system prune -af`, which removes **all Docker images** present on the machine, not just those of this project. If other Docker projects are present on the same VM, their images will also be removed.

## Container and volume management commands
Here is a list of commands useful for diagnosis and inspection:

- `docker compose -f ./srcs/docker-compose.yml ps` (or `docker ps`) : shows the status of each service (`Up`, `Restarting`, `Exited`).
- `docker logs <service_name>` : shows the output of a container in order to find a potential issue.
- `docker exec <service_name> <command>` : runs a command without entering interactive mode, useful for checking a file, for example.
- `docker exec -it <service_name> /bin/bash` (or `/bin/sh`) : opens a terminal inside the container in order to explore it further.
- `docker compose -f ./srcs/docker-compose.yml config` : displays the resolved compose configuration with all variables substituted, useful for diagnosing an issue with environment variables (`./srcs/.env`).
- `docker volume ls` : lists all Docker volumes existing on the machine.
- `docker volume inspect <volume_name>` : shows the details of a specific volume.
- `docker network ls` or `docker network inspect inception` (`inception` being the name of this project's network) : allows checking that the containers are indeed on the same network.

## Data location and persistence
### Where the data is actually stored
The project contains three named volumes, `mariadb`, `wordpress`, and `backup_mariadb`, physically stored on the host respectively in `/home/<LOGIN>/data/mariadb`, `/home/<LOGIN>/data/wordpress`, and `/home/<LOGIN>/data/backup_mariadb`. This location can be changed in `./srcs/docker-compose.yml`, by editing the `device:` field inside `driver_opts` for the volume in question.

The `mariadb` volume contains the database files (it corresponds to `/var/lib/mysql` inside the container).

The `wordpress` volume contains the site's files (WordPress core, themes, uploaded media, etc.) (it corresponds to `/var/www/html` inside the container). This same volume is also mounted inside the `ftp` container (FTP bonus), to provide direct access to the files via the FTP protocol.

The `backup_mariadb` volume (Backup MariaDB bonus) contains the hourly database backups generated by `mysqldump` (it corresponds to `/backups` inside the `backup_mariadb` container).

### How to actually check/explore this data
There are two ways to explore the data.

Knowing the location of the data, it is possible to go directly into the folders (`/home/<LOGIN>/data/...`) without going through Docker, using basic commands such as `cd`, `ls`, `cat`, a file explorer, etc.

It is also possible to go through Docker via the commands seen previously (`docker volume ls`, `docker volume inspect <name>`, etc.).

### What persists, and what does not
Data persists in two cases: during an automatic restart following a crash (thanks to `restart: on-failure`), and during a `make down`, which simply stops the containers without removing the volumes or the data.

Conversely, the `make clean`, `make fclean`, and `make re` commands remove the Docker volumes as well as the physical `/home/<LOGIN>/data` folder: the data is then permanently lost. `make fclean` (and therefore `make re`, which runs it) goes even further by also removing all Docker images present on the machine.

> For the Backup MariaDB bonus, a 24-hour retention policy applies in addition to the above: even without manual intervention, backups in the `backup_mariadb` volume older than 24 hours are automatically deleted by the `backup.sh` script, which runs every hour via `cron`.