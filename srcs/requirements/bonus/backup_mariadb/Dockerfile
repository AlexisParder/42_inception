FROM debian:bookworm

RUN apt update -y && apt install -y cron mariadb-client

RUN mkdir -p /backups

COPY ./conf/backup.cron /etc/cron.d/backup.cron

COPY ./tools/backup.sh /backup.sh
RUN chmod +x /backup.sh

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]