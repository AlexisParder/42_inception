# User documentation
- [User documentation](#user-documentation)
	- [Overview of the services](#overview-of-the-services)
	- [Using the project](#using-the-project)
	- [Accessing the website and admin panel](#accessing-the-website-and-admin-panel)
	- [Locating and managing credentials](#locating-and-managing-credentials)
	- [Checking that the services are running correctly](#checking-that-the-services-are-running-correctly)

## Overview of the services
This project consists of several Docker services (containers).

Mandatory containers (required by the subject):
- `NGINX` => Provides access to the website from a browser over HTTPS (Hypertext Transfer Protocol Secure), in other words securely.
- `WordPress` => This is the CMS (Content Management System), it runs the website, this is what the end user sees when visiting the site.
- `MariaDB` => Database used to store the information needed by the WordPress site, such as users, pages, etc.

Bonus containers:
- `redis-cache` => Optimizes site performance by caching selected data.
- `ftp` => Enables an FTP connection to upload, download, and browse the website's files.
  - To connect via FTP from the command line: `lftp <FTP_USER>@<HOST_IP>` or `ftp <FTP_USER>@<HOST_IP>`
    - To find `HOST_IP`, run the following command in a terminal: `ip route get 1.1.1.1 | awk '{print $7; exit}'`
- `static_website` => Static showcase website, accessible independently from the main WordPress site via `https://static.<DOMAIN_NAME>:8443`.
	> **Note:** The `8443` port is required. Without it, the browser will use the default HTTPS port (`443`), which serves the main WordPress site instead.
- `adminer` => A web interface for managing databases, similar to phpMyAdmin. To access it, visit `https://adminer.<DOMAIN_NAME>:8444`. Login credentials can be found in the `Locating and managing credentials` section below.
	> **Note:** The `8444` port is required. Without it, the browser will use the default HTTPS port (`443`), which serves the main WordPress site instead.
- `backup mariadb` => A system that performs a database backup every hour using `cron` and automatically removes backups older than 24 hours to prevent excessive disk usage. Backups are stored in the `/home/<LOGIN>/data/backup_mariadb` directory.

## Using the project
Here is a list of commands to start, stop, and clean up the project:

- `make` => Prepares the environment and then starts the services.
- `make down` => Stops all services.
- `make clean` => Stops all services and removes stored data.
- `make fclean` => Stops all services and removes everything that was previously created.
- `make re` => Removes everything and reinstalls it cleanly (as if it were the project's first startup).

## Accessing the website and admin panel
The website can be accessed via the URL `https://<DOMAIN_NAME>`. To find your `<DOMAIN_NAME>`, open the file `./srcs/.env`, where you'll find the line `DOMAIN_NAME=...`.

A browser warning will appear; this is normal, as the TLS certificate is self-signed (in other words, it is not issued by a recognized authority). Simply accept the "risk" to continue, and you'll then have access to the site.

To log in to the admin panel, go to `https://<DOMAIN_NAME>/wp-admin`.

## Locating and managing credentials
**WordPress Administrator**
- Username: `WP_USER` variable in `./srcs/.env`
- Password: in `./secrets/wp_admin_password.txt`
- Role: administrator (full rights over the site)

**WordPress User (secondary)**
- Username: `WP_USER2` variable in `./srcs/.env`
- Password: in `./secrets/wp_user_password.txt`
- Role: editor (can manage content but does not have full site administration rights)

**Database User**
- Username: `DB_USER` variable in `./srcs/.env`
- Password: in `./secrets/db_password.txt`

**Database Administrator**
- Username: `root`
- Password: in `./secrets/db_root_password.txt`

**FTP User**
- Username: `FTP_USER` variable in `./srcs/.env`
- Password: in `./secrets/ftp_password.txt`

**Adminer**
- Server: `mariadb`
- Username: `DB_USER` variable in `./srcs/.env`
- Password: in `./secrets/db_password.txt`
- Database: Leave this empty, or use the value of `DB_NAME` from `./srcs/.env`

## Checking that the services are running correctly
A simple command is `docker ps`, which will display the installed services and their status (`Up`: good, `Restarting` or `Exited`: there is a problem).

If there's an issue, you can run the command `docker logs <service_name>`, which can help you understand the cause of the problem.

Finally, the simplest test is to try accessing the site: if the WordPress page loads, everything is working.