FROM debian:bookworm

RUN apt update -y && apt install -y vsftpd gettext-base

RUN mkdir -p /etc/vsftpd/templates

COPY ./conf/vsftpd.conf.template /etc/vsftpd/templates/vsftpd.conf.template

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /var/run/vsftpd/empty

EXPOSE 21

ENTRYPOINT ["/entrypoint.sh"]
CMD ["vsftpd", "/etc/vsftpd.conf"]