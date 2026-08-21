#!/usr/bin/env bash
# Reachability only — does not spoil attack paths.
set -euo pipefail
cd "$(dirname "$0")"

fail=0
check_http() {
  local url=$1
  if curl -fsS -m 3 "$url" >/dev/null; then
    echo "OK  http $url"
  else
    echo "FAIL http $url"
    fail=1
  fi
}

echo "== compose =="
docker compose ps

echo
echo "== published loopback ports =="
check_http http://127.0.0.1:8011/
check_http http://127.0.0.1:8012/
check_http http://127.0.0.1:8013/
check_http http://127.0.0.1:8021/

echo
echo "== DMZ bridge (may work on Linux docker hosts) =="
for ip in 172.28.10.11 172.28.10.12 172.28.10.13 172.28.10.21; do
  if curl -fsS -m 2 "http://${ip}/" >/dev/null; then
    echo "OK  http://${ip}/"
  else
    echo "SKIP/FAIL http://${ip}/ (use 127.0.0.1 published ports)"
  fi
done

echo
echo "== internal net must NOT be reachable from the host =="
if curl -fsS -m 2 http://172.28.20.12/ >/dev/null 2>&1; then
  echo "FAIL APP01 is reachable from host — run ./isolate-internal.sh (sudo)"
  fail=1
else
  echo "OK  172.28.20.12 not reachable from host (pivot through MS01)"
fi

exit "$fail"
