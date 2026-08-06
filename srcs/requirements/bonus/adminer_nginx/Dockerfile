FROM debian:bookworm

RUN apt update -y && apt install -y nginx openssl gettext-base

RUN mkdir -p /etc/nginx/ssl
RUN mkdir -p /etc/nginx/templates

COPY ./conf/nginx.conf.template /etc/nginx/templates/nginx.conf.template

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8444

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]