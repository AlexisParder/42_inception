# inception
![42 Cursus](https://img.shields.io/badge/42-Cursus-blue?style=for-the-badge)
![Projects](https://img.shields.io/badge/Projects-Common_Core-success?style=for-the-badge)
![Score](https://img.shields.io/badge/score-125%20%2F%20100-success?style=for-the-badge)<br>
[🇫🇷 Français](./README.md)
- [inception](#inception)
	- [Description](#description)
	- [Instructions](#instructions)
		- [Prerequisites](#prerequisites)
		- [Configuration](#configuration)
		- [Commands](#commands)
		- [Bonus](#bonus)
	- [Technical choices and architecture](#technical-choices-and-architecture)
		- [Virtual Machines (VM) vs Docker](#virtual-machines-vm-vs-docker)
		- [Secrets vs Environment Variables](#secrets-vs-environment-variables)
		- [Docker Network vs Host Network](#docker-network-vs-host-network)
		- [Docker Volumes vs Bind Mounts](#docker-volumes-vs-bind-mounts)
	- [Use of AI](#use-of-ai)
	- [Resources](#resources)

## Description
A service virtualization and orchestration project based on Docker. The goal is to set up a multi-container infrastructure including an NGINX web server, WordPress with PHP-FPM and a MariaDB database, all configured manually without relying on pre-built Docker images. The project requires mastery of Dockerfiles, volumes, Docker networks and service configuration in an isolated environment. This project builds strong skills in modern system administration, containerized infrastructure deployment and web service hardening.

## Instructions
### Prerequisites
- Docker
- Docker Compose
- Debian environment (Linux)

### Configuration
- Clone the project
- Configure `.env`.
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
	> For the domain `<DOMAIN_NAME>` to be resolved locally, open the `/etc/hosts` file (with administrator privileges) and add the following lines:
    >- `127.0.0.1 <DOMAIN_NAME>`
    >- `127.0.0.1 static.<DOMAIN_NAME>`
    >- `127.0.0.1 adminer.<DOMAIN_NAME>`

- Configure the `secrets` (this is where the passwords are stored)
  - Create a `secrets` folder at the root of the project (at the same level as `srcs`).
  - Create the files below inside the `secrets` folder
	- `db_password.txt` => password of the database user
	- `db_root_password.txt` => password of the database administrator (`root`)
	- `wp_admin_password.txt` => password of the WordPress administrator (corresponds to `WP_USER` in `.env`)
	- `wp_user_password.txt` => password of the WordPress user (corresponds to `WP_USER2` in `.env`)
    - `ftp_password.txt` => password of the user (corresponds to `FTP_USER` in `.env`) for the FTP bonus
	> Each of these files must contain only the corresponding password, nothing else: no line break, no space, no newline before or after the value.

### Commands
- Once the configuration is complete, open a terminal and go to the root of this folder.
- Several commands are available
  - `make` : Build the Docker images, run the configuration, and start the different services.
  - `make build` : Build (or rebuild, if necessary) the Docker images, apply the configuration, and start all services.
  - `make down` : Stop the services (`make` will restart them).
  - `make clean` : Stop the services and clean the data created in `/home/<LOGIN>/data`.
  - `make fclean` : Stop the services, clean everything, and remove everything that was created by the `make` command.
  - `make re` : Removes everything and reinstalls the services from scratch (equivalent to running `make fclean` then `make`).

### Bonus
In addition to the mandatory part, this project implements the following bonuses:
- `Redis` : caching of `WordPress` objects via the `redis-cache` plugin, which reduces the number of requests made to the `MariaDB` database and speeds up site loading.
- `FTP` : a `vsftpd` server provides direct access (read/write) to the WordPress files volume via the `FTP` protocol, in passive mode. Since the host's IP address can change (VM on a shared workstation), it is dynamically detected at launch by the Makefile and passed to the container, so that the `pasv_address` configuration always stays consistent with the actual environment.
- `Static website` : a second NGINX container serves a static showcase website (HTML/CSS, based on a Frontend Mentor template), completely independent from WordPress. It is exposed on a dedicated port (`8443`) instead of the main port `443`, in order to respect the subject's constraint. It is accessible via the subdomain `static.<DOMAIN_NAME>`, provided the port is specified in the URL (`https://static.<DOMAIN_NAME>:8443`).
- `Adminer` => a web interface for managing databases, similar to phpMyAdmin. It is exposed on a dedicated port (`8444`) instead of the main port `443`, in order to respect the subject's constraint. It is accessible via the subdomain `adminer.<DOMAIN_NAME>`, provided the port is specified in the URL (`https://adminer.<DOMAIN_NAME>:8444`). For this bonus, I chose to create two separate containers, `adminer` (PHP-FPM, hosting the application itself) and `adminer_nginx` (the web server dedicated to it), in order to respect the "one service = one container" principle (the exact same pattern used between nginx and wordpress in the mandatory part).
- `Backup MariaDB` : a dedicated container runs `mysqldump` every hour via `cron`, saving the database into a separate named volume (`backup_mariadb`), with a 24-hour retention policy (older backups are automatically deleted). This service was chosen because it addresses a concrete system administration need: protecting data against corruption, human error, or accidental loss, without relying solely on the persistence of the main volume.

## Technical choices and architecture
### Virtual Machines (VM) vs Docker
Even regardless of the subject's requirement, working inside a virtual machine (`VM`) remains relevant: it provides an `isolated environment` for testing, avoids damaging the school's computer, and grants administrator permissions on our environment through `sudo`.

Regarding the `difference` between a `VM` and `Docker`, it mainly lies in the fact that Docker images are far less heavy than a VM and therefore take up less disk space. In addition, Docker allows automatic installation of the dependencies needed for each service.

### Secrets vs Environment Variables
The main difference truly lies in security. Whereas a classic environment variable (`.env`) is visible in plain text when inspecting the container (`docker inspect`, `docker exec`, or even `docker compose config`), a `Docker Secret` is treated as a file and is made available at `/run/secrets/<name>` in read-only mode. It therefore cannot be viewed through commands like `docker inspect`, nor through the container's environment variables, which represents a real security improvement over `.env` alone.

For my project, I chose to use both: `.env` for non-sensitive information such as the domain name, the database name, etc., and separate `secret` files stored in the `secrets` directory, each containing a single password or sensitive value.

It remains necessary to add `secrets/` and `.env` to `.gitignore` so they are never pushed to GitHub and therefore never publicly exposed.

### Docker Network vs Host Network
The `network:` setting allows the creation of a virtual network. If `network: host` (the host's network) is used, the container then uses the `direct network` of the `host machine`, meaning containers such as nginx would no longer be separated from the host machine and would therefore be on the same network. In addition, a `host network exposes all of its open ports`, meaning any port opened by the host becomes `accessible` to anyone from `outside` the `VM`; an attacker would then have a network access identical to what they would have by attacking the VM directly (security flaw). One last important point: there could be port conflicts between containers, since two services cannot listen on the same port.

For all these reasons, I chose to use a Docker network: better security, the separation between containers and the host preventing full access in case of an attack, by only exposing the wanted ports such as `443`. In addition, several services can listen on the same port without conflicts, each isolated within its own network. Another advantage of the Docker network is that it provides automatic internal DNS resolution between containers: they can communicate with each other directly by service name, without knowing its IP address. This is, for example, what I use in my `nginx` configuration with `fastcgi_pass wordpress:9000`, or in my `WordPress script` with `--dbhost=mariadb` to connect to the database.

### Docker Volumes vs Bind Mounts
The main difference lies in where the data is stored and how it is accessed. A `bind mount` stores the data at the location specified in the configuration: this location is therefore precisely known, and can be accessed directly from the host whenever desired, for example `/home/<LOGIN>/data`. As a result, anyone who knows the storage location can browse the data directly on the host, without going through Docker.

A `named volume`, on the other hand, stores the data inside a volume identified by the name given to it, but by default its actual physical location on the host is unknown. It cannot be accessed directly: it is necessary to always go through the name assigned to it, and therefore through dedicated Docker commands (`docker volume ls`, `docker volume inspect`, etc.).

In this project, I use `named volumes` for `mariadb` and `wordpress`, as required by the subject, but with a specific configuration: the `driver_opts` parameter (with `device:`, `o: bind`, and `type: none`) allows precise control over the physical location where Docker stores the data of these volumes on the host, namely `/home/<LOGIN>/data/mariadb` and `/home/<LOGIN>/data/wordpress`, as required by the subject.

This mechanism remains a `named volume` from `Docker`'s point of view: it is created and managed by `Docker`, it appears in `docker volume ls`, and it is referenced by its name (`mariadb`, `wordpress`) in each service's definition, rather than by a path written directly inside a service's `volumes:` section (which would, in that case, be a true bind mount). The presence of `o: bind` in `driver_opts` does not change this nature: it only tells Docker's local driver how to link the volume to the disk. This is the most direct solution I found to satisfy both the requirement to use `named volumes` and the requirement to have the data physically visible in `/home/<LOGIN>/data` on the host machine.

## Use of AI
Artificial intelligence was used as a support to understand and consolidate the key concepts of the project, and to make sure I had grasped the essentials for the explanations above.

## Resources
- [Docker - nicelyDev.com](https://www.nicelydev.com/docker)
- [Nginx - nicelyDev.com](https://www.nicelydev.com/nginx)
- [Secrets Docker](https://blog.stephane-robert.info/docs/conteneurs/moteurs-conteneurs/docker/secrets/)
- [Docker - IT Connect](https://www.it-connect.fr/installation-pas-a-pas-de-docker-sur-debian-11/)
- [(Video FR) Docker - Grafikart](https://grafikart.fr/tutoriels/docker)