#!/bin/bash
# Nightly web backup — keep this non-writable. (It is writable. That is the lab.)
tar czf /tmp/www-backup.tar.gz /var/www/localhost/htdocs >/dev/null 2>&1 || true
