# inception
![42 Cursus](https://img.shields.io/badge/42-Cursus-blue?style=for-the-badge)
![Projects](https://img.shields.io/badge/Projects-Common_Core-success?style=for-the-badge)
![Score](https://img.shields.io/badge/score-125%20%2F%20100-success?style=for-the-badge)<br>
[🇬🇧 English](./README_EN.md)
- [inception](#inception)
	- [Description](#description)
	- [Instructions](#instructions)
		- [Prérequis](#prérequis)
		- [Configuration](#configuration)
		- [Commandes](#commandes)
		- [Bonus](#bonus)
	- [Choix techniques et architecture](#choix-techniques-et-architecture)
		- [Machines virtuelles (VM) vs Docker](#machines-virtuelles-vm-vs-docker)
		- [Secrets vs Variables d’environnement](#secrets-vs-variables-denvironnement)
		- [Réseau Docker vs Réseau de l’hôte](#réseau-docker-vs-réseau-de-lhôte)
		- [Volumes Docker vs Montages Bind (Bind Mounts)](#volumes-docker-vs-montages-bind-bind-mounts)
	- [Utilisation de l’IA](#utilisation-de-lia)
	- [Ressources](#ressources)

## Description
Un projet de virtualisation et d'orchestration de services basé sur Docker. L'objectif est de mettre en place une infrastructure multi-conteneurs comprenant un serveur web NGINX, WordPress avec PHP-FPM et une base de données MariaDB, le tout configuré manuellement sans recourir à des images Docker prêtes à l'emploi. Le projet impose une maîtrise des Dockerfiles, des volumes, des réseaux Docker et de la configuration des services en environnement isolé. Ce projet développe des compétences solides en administration système moderne, en déploiement d'infrastructures conteneurisées et en sécurisation des services web.

## Instructions
### Prérequis
- Docker
- Docker compose
- Environnement debian (Linux)

### Configuration
- Cloner le projet
- Configurer `.env`.
  - Se rendre dans `./srcs/`
  - Créer un fichier `.env`
  - Remplir le fichier comme l'exemple ci-dessous
	```env
	# Correspond a votre utilisateur debian
	LOGIN=...

	# Utilisateur et nom de la base de donnée
	DB_USER=...
	DB_NAME=...

	# Domaine complet, exemple: <LOGIN>.42.fr
	DOMAIN_NAME=...

	# Compte Administrateur WordPress
	WP_USER=...
	WP_MAIL=...

	# Compte Utilisateur WordPress
	WP_USER2=...
	WP_MAIL2=...

	# BONUS FTP: Compte utilisateur pour ftp
	FTP_USER=...
	```
	> Pour que le domaine `<DOMAIN_NAME>` soit résolu localement, ouvrez le fichier `/etc/hosts` (avec les droits `administrateur`) et ajoutez les lignes:
    >- `127.0.0.1 <DOMAIN_NAME>`
    >- `127.0.0.1 static.<DOMAIN_NAME>`
    >- `127.0.0.1 adminer.<DOMAIN_NAME>`

- Configurer les `secrets` (c'est ce qui contient les mots de passe)
  - Créer un dossier `secrets` a la racine du projet (au meme niveau que `srcs`).
  - Créer les fichiers ci-dessous dans le dossier `secrets`
	- `db_password.txt` => mot de passe de l'utilisateur pour la base de donnée
	- `db_root_password.txt` => mot de passe de l'administrateur (`root`) pour la base de donnée
	- `wp_admin_password.txt` => mot de passe de l'administrateur (correspond à `WP_USER` dans le `.env`) pour wordpress
	- `wp_user_password.txt` => mot de passe de l'utilisateur (correspond à `WP_USER2` dans le `.env`) pour wordpress
    - `ftp_password.txt` => mot de passe de l'utilisateur (correspond à `FTP_USER` dans le `.env`) pour le bonus ftp
	> Chacun de ces fichiers doit contenir uniquement le mot de passe correspondant, sans rien d'autre : pas de saut de ligne, pas d'espace, pas de retour à la ligne avant ou après la valeur.

### Commandes
- Une fois la configuration terminée, ouvrez un terminal et placez vous à la racine de ce dossier.
- Plusieurs commande seront disponibles
  - `make` : Créer les images docker, lancer la configuration et lancer les differents services.
  - `make build` : Créer les images docker (et les recréer si les images sont deja existantes), lancer la configuration et lancer les differents services.
  - `make down` : Eteindre les services (`make` permettra de les rallumer).
  - `make clean` : Eteindre les services et nettoyer les donnees créée dans `/home/<LOGIN>/data`.
  - `make fclean` : Eteindre les services, tout nettoyer, supprimer tous ce qui a été créé par la commande `make`.
  - `make re` : Supprime tout et réinstalle les services de zéro (revient à faire `make fclean` puis `make`).

### Bonus
En plus de la partie obligatoire, ce projet implémente les bonus suivants :
- `Redis` : mise en cache des objets `WordPress` via le plugin `redis-cache`, ce qui réduit le nombre de requêtes effectuées vers la base de données `MariaDB` et accélère le chargement du site.
- `FTP` : un serveur `vsftpd` donne un accès direct (en lecture/écriture) au volume des fichiers WordPress via le protocole `FTP`, en mode passif. L'adresse IP de l'hôte étant potentiellement changeante (VM sur poste partagé), elle est détectée dynamiquement au lancement par le Makefile et transmise au conteneur, afin que la configuration `pasv_address` reste toujours cohérente avec l'environnement réel.
- `Site statique` : un second conteneur NGINX sert un site vitrine statique (HTML/CSS, basé sur un template Frontend Mentor), totalement indépendant de WordPress. Il est exposé sur un port dédié (`8443`) plutôt que sur le port `443` principal, afin de respecter la contrainte du sujet. Il est accessible via le sous-domaine `static.<DOMAIN_NAME>`, à condition de préciser le port dans l'URL (`https://static.<DOMAIN_NAME>:8443`).
- `Adminer` => interface web permettant de gérer les bases de données, comme phpMyAdmin. Il est exposé sur un port dédié (`8444`) plutôt que sur le port `443` principal, afin de respecter la contrainte du sujet. Il est accessible via le sous-domaine `adminer.<DOMAIN_NAME>`, à condition de préciser le port dans l'URL (`https://adminer.<DOMAIN_NAME>:8444`). Pour ce bonus, j'ai choisi de créer deux conteneurs séparés, `adminer` (PHP-FPM, qui héberge l'application elle-même) et `adminer_nginx` (le serveur web qui lui est dédié), afin de respecter le principe `un service = un conteneur` (exactement le même schéma que celui utilisé entre nginx et wordpress dans la mandatory part).
- `Backup MariaDB` : un conteneur dédié exécute `mysqldump` toutes les heures via `cron`, sauvegardant la base de données dans un volume nommé distinct (`backup_mariadb`), avec une rétention de 24 heures (les sauvegardes plus anciennes sont automatiquement supprimées). Ce service a été choisi car il répond à un besoin concret d'administration système : protéger les données contre une corruption, une erreur humaine, ou une perte accidentelle, sans dépendre uniquement de la persistance du volume principal.

## Choix techniques et architecture
### Machines virtuelles (VM) vs Docker
Même indépendamment de l'obligation du sujet, `travailler` dans une machine virtuelle (`VM`) reste pertinent : cela permet d'avoir un `environnement isolé` pour faire les tests, d'éviter d'endommager l'ordinateur de l'école, et de disposer des permissions administrateur sur notre environnement grâce à `sudo`.

Concernant la `différence` entre une `VM` et `Docker`, elle réside principalement dans le fait que les images Docker sont beaucoup moins volumineuses qu'une VM et prennent donc moins de place sur le disque. De plus, Docker permet l'installation automatique des dépendances nécessaires pour chaque service.

### Secrets vs Variables d’environnement
La différence principale réside vraiment dans la sécurité. Là où une variable d'environnement classique (`.env`) est visible en clair en inspectant le conteneur (`docker inspect`, `docker exec`, ou même `docker compose config`), un `Secret Docker`, lui, est considéré comme un fichier et est présent dans `/run/secrets/<nom>` en lecture seule. Il ne peut donc pas être consulté via des commandes comme `docker inspect` ni via les variables d'environnement du conteneur, ce qui représente une réelle amélioration de sécurité par rapport au `.env` seul.

Pour mon projet, j'ai choisi d'utiliser les deux : le `.env` pour les informations non sensibles comme le nom de domaine, le nom de la base de données, etc., et les `secrets` répartis en plusieurs fichiers distincts dans le dossier `secrets`, chacun contenant un mot de passe.

Il reste nécessaire d'ajouter `secrets/` et `.env` au `.gitignore` pour ne pas les envoyer sur GitHub et donc ne pas les exposer publiquement.

### Réseau Docker vs Réseau de l’hôte
Le `network:` permet la création d'un réseau virtuel. Si l'on utilise `network: host` (le réseau de l'hôte), on utilise alors le `réseau direct` de la `machine hôte`, autrement dit les conteneurs tels que nginx ne seraient plus séparés de la machine hôte et donc sur le même réseau. De plus, un `réseau hôte expose tous ses ports ouverts`, cela veut dire que tout port ouvert par l'hôte est `accessible` par n'importe qui depuis l'`extérieur` de la `VM`, un attaquant aurait alors un accès réseau identique à celui qu'il aurait en attaquant directement la VM (faille de sécurité). Dernier point important : il pourrait y avoir des conflits de ports entre les conteneurs, deux services ne pouvant pas écouter sur le même port.

C'est pour toutes ces raisons que j'ai choisi d'utiliser un réseau Docker : une meilleure sécurité, la séparation des conteneurs et de l'hôte ne donnant pas un accès complet en cas d'attaque, en n'exposant que les ports voulus comme le `443`. De plus, plusieurs services peuvent écouter sur le même port sans conflits, chacun isolé dans son propre réseau. Un autre avantage du réseau Docker est qu'il fournit une résolution DNS interne automatique entre les conteneurs : ils peuvent communiquer entre eux directement par le nom du service, sans connaître son adresse IP. C'est par exemple ce que j'utilise dans ma configuration `nginx` avec `fastcgi_pass wordpress:9000`, ou dans mon `script WordPress` avec `--dbhost=mariadb` pour se connecter à la base de données.

### Volumes Docker vs Montages Bind (Bind Mounts)
La principale différence réside dans l'endroit où sont stockées les données et comment y accéder. Le `montage bind` (Bind Mount) va stocker les données à l'endroit spécifié dans la configuration : on connaît alors précisément cet endroit et on peut y accéder directement depuis l'hôte quand on le souhaite, comme par exemple `/home/<LOGIN>/data`. De ce fait, n'importe qui connaissant l'endroit de stockage peut aller fouiller les données directement sur l'hôte, sans passer par Docker.

Le `named volume`, lui, va stocker les données dans un volume portant le nom qu'on lui aura donné, mais on ne sait pas (par défaut) où il sera stocké physiquement sur l'hôte. On n'y a pas accès directement : il faut systématiquement passer par le nom qu'on lui a attribué, et donc par les commandes Docker dédiées (`docker volume ls`, `docker volume inspect`, etc.).

Dans ce projet, j'utilise des `named volumes` pour `mariadb` et `wordpress`, comme l'exige le sujet, mais avec une configuration particulière : le paramètre `driver_opts` (avec `device:`, `o: bind` et `type: none`) permet de contrôler l'emplacement physique exact où Docker va stocker les données de ces volumes sur l'hôte, à savoir `/home/<LOGIN>/data/mariadb` et `/home/<LOGIN>/data/wordpress`, comme demandé par le sujet.

Ce mécanisme reste un `named volume` au sens de `Docker` : il est créé et géré par `Docker`, il apparaît dans `docker volume ls`, et il est référencé par son nom (`mariadb`, `wordpress`) dans la définition de chaque service, et non par un chemin écrit directement dans la section `volumes:` d'un service (ce qui serait, lui, un vrai bind mount). La présence de `o: bind` dans `driver_opts` ne change pas cette nature : elle indique seulement au driver local de Docker comment lier le volume au disque. C'est la solution la plus directe que j'ai trouve pour respecter à la fois l'exigence d'utiliser des `named volumes` et celle d'avoir les données physiquement visibles dans `/home/<LOGIN>/data` sur la machine hôte.

## Utilisation de l’IA
L’intelligence artificielle a été utilisée comme support pour comprendre et regrouper les notions clés du projet et m'assurer d'avoir retenu l'essentiel pour les explications ci-dessus.

## Ressources
- [Docker - nicelyDev.com](https://www.nicelydev.com/docker)
- [Nginx - nicelyDev.com](https://www.nicelydev.com/nginx)
- [Secrets Docker](https://blog.stephane-robert.info/docs/conteneurs/moteurs-conteneurs/docker/secrets/)
- [Docker - IT Connect](https://www.it-connect.fr/installation-pas-a-pas-de-docker-sur-debian-11/)
- [(Video FR) Docker - Grafikart](https://grafikart.fr/tutoriels/docker)