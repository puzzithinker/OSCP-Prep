FROM alpine:3.20 AS build
RUN apk add --no-cache gcc musl-dev
WORKDIR /build
COPY src/dbmaint.c .
RUN gcc -o dbmaint dbmaint.c

FROM alpine:3.20
RUN apk add --no-cache \
      apache2 php82 php82-apache2 php82-sqlite3 php82-session \
      openssh sudo bash python3 iproute2 findutils \
      dcron coreutils shadow \
    && mkdir -p /run/apache2 /run/sshd /opt/lab /var/www/localhost/htdocs

COPY --from=build /build/dbmaint /opt/lab/dbmaint
COPY apache/lab.conf /etc/apache2/conf.d/lab.conf
COPY content/ /opt/content/
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
    && printf '\nPasswordAuthentication yes\nPubkeyAuthentication yes\nPermitRootLogin no\nUseDNS no\n' >> /etc/ssh/sshd_config \
    && printf 'display_errors=On\nallow_url_include=Off\n' >/etc/php82/conf.d/99-lab.ini

EXPOSE 80 22
ENTRYPOINT ["/entrypoint.sh"]
