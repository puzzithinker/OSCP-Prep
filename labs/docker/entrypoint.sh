#!/bin/bash
set -euo pipefail

LAB="${LAB:?LAB env is required (harbor|ledger|catalog|ms01|app01|dc01)}"
WWW="/var/www/localhost/htdocs"
CONTENT="/opt/content/${LAB}"

mkdir -p /run/apache2 /run/sshd /run/crond "$WWW"

if ! grep -q 'php_module' /etc/apache2/httpd.conf /etc/apache2/conf.d/*.conf 2>/dev/null; then
  cat >/etc/apache2/conf.d/php82-module.conf <<'EOF'
LoadModule php_module modules/mod_php82.so
EOF
fi

# Drop alpine default User apache is fine; give apache a real home + shell.
usermod -s /bin/bash apache 2>/dev/null || true
mkdir -p /home/apache
chown apache:apache /home/apache

write_flag() {
  local path="$1" value="$2" owner="$3"
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$value" >"$path"
  chown "$owner" "$path"
  chmod 644 "$path"
}

install_www() {
  rm -rf "${WWW:?}/"*
  mkdir -p "$WWW"
  if [[ -d "$CONTENT/www" ]]; then
    cp -a "$CONTENT/www/." "$WWW/"
  fi
  chown -R apache:apache "$WWW"
}

ensure_user() {
  local name="$1" pass="$2" home="$3"
  if ! id "$name" >/dev/null 2>&1; then
    adduser -D -s /bin/bash -h "$home" "$name"
  fi
  echo "${name}:${pass}" | chpasswd
  mkdir -p "$home"
  chown -R "${name}:${name}" "$home"
}

install_www

case "$LAB" in
  harbor)
    write_flag /home/apache/local.txt "OSCP-PREP-local-harbor-7c4e91aa" apache:apache
    write_flag /root/proof.txt "OSCP-PREP-proof-harbor-b1d83f02" root:root
    chmod 600 /root/proof.txt
    cp /opt/content/harbor/backup.sh /usr/local/bin/backup.sh
    chmod 777 /usr/local/bin/backup.sh
    printf '* * * * * /usr/local/bin/backup.sh\n' >/etc/crontabs/root
    mkdir -p "$WWW/uploads" "$WWW/backup"
    chown -R apache:apache "$WWW"
    ;;
  ledger)
    ensure_user dev 'LedgerDev2024!' /home/dev
    write_flag /home/dev/local.txt "OSCP-PREP-local-ledger-2e91c0bb" dev:dev
    write_flag /root/proof.txt "OSCP-PREP-proof-ledger-88a14d77" root:root
    chmod 600 /root/proof.txt
    cp /opt/content/ledger/notes.txt /home/dev/notes.txt
    mkdir -p /home/dev/.ssh
    if [[ ! -f /home/dev/.ssh/id_rsa ]]; then
      ssh-keygen -t rsa -b 2048 -f /home/dev/.ssh/id_rsa -N '' -q
    fi
    cat /home/dev/.ssh/id_rsa.pub >/home/dev/.ssh/authorized_keys
    # 711 = others can traverse (LFI) but not list; not other-writable (sshd StrictModes)
    chmod 755 /home/dev
    chmod 711 /home/dev/.ssh
    chmod 644 /home/dev/.ssh/id_rsa /home/dev/notes.txt
    chmod 600 /home/dev/.ssh/authorized_keys
    chown -R dev:dev /home/dev
    echo 'dev ALL=(root) NOPASSWD: /usr/bin/find' >/etc/sudoers.d/dev
    chmod 440 /etc/sudoers.d/dev
    ;;
  catalog)
    ensure_user catalog_admin 'SummerCatalog1' /home/catalog_admin
    write_flag /home/catalog_admin/local.txt "OSCP-PREP-local-catalog-c5a02e19" catalog_admin:catalog_admin
    write_flag /root/proof.txt "OSCP-PREP-proof-catalog-4b77e3d0" root:root
    chmod 600 /root/proof.txt
    PHP_BIN="$(command -v php82 || command -v php)"
    "$PHP_BIN" /opt/content/catalog/seed.php
    chown apache:apache /opt/catalog.db
    chmod 664 /opt/catalog.db
    cp /opt/lab/dbmaint /usr/local/bin/dbmaint
    chown root:root /usr/local/bin/dbmaint
    chmod 4755 /usr/local/bin/dbmaint
    ;;
  ms01)
    ensure_user jdoe 'Winter2024!' /home/jdoe
    write_flag /home/jdoe/local.txt "OSCP-PREP-local-ms01-11d4a8c3" jdoe:jdoe
    write_flag /root/proof.txt "OSCP-PREP-proof-ms01-unused" root:root
    chmod 600 /root/proof.txt
    mkdir -p /home/jdoe/Documents
    cp /opt/content/ms01/todo.txt /home/jdoe/Documents/todo.txt
    cp /opt/content/ms01/bash_history /home/jdoe/.bash_history
    chown -R jdoe:jdoe /home/jdoe
    chmod 644 /home/jdoe/Documents/todo.txt /home/jdoe/.bash_history
    ;;
  app01)
    ensure_user svc_backup 'Summer2024!' /home/svc_backup
    write_flag /home/svc_backup/local.txt "OSCP-PREP-local-app01-9f30be64" svc_backup:svc_backup
    write_flag /root/proof.txt "OSCP-PREP-proof-app01-unused" root:root
    chmod 600 /root/proof.txt
    chown apache:apache "$WWW/config.php"
    chmod 644 "$WWW/config.php"
    ;;
  dc01)
    ensure_user northwind_admin 'NorthwindDA!' /home/northwind_admin
    write_flag /home/northwind_admin/local.txt "OSCP-PREP-local-dc01-e8c21a50" northwind_admin:northwind_admin
    write_flag /root/proof.txt "OSCP-PREP-proof-dc01-da-6f91ab2e" root:root
    chmod 600 /root/proof.txt
    echo 'northwind_admin ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/nw
    chmod 440 /etc/sudoers.d/nw
    mkdir -p /opt/domain
    printf 'jdoe,staff\nsvc_backup,svc\nnorthwind_admin,Domain Admins analog\n' >/opt/domain/users.csv
    ;;
  *)
    echo "Unknown LAB=$LAB" >&2
    exit 1
    ;;
esac

if [[ ! -f /etc/ssh/ssh_host_ed25519_key ]]; then
  ssh-keygen -A
fi

# Banner with hostname for proof screenshots
printf 'OSCP-prep lab: %s\n' "$(hostname)" >/etc/motd

crond
/usr/sbin/sshd
exec httpd -D FOREGROUND
