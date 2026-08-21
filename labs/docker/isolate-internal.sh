#!/usr/bin/env bash
# Remove the host's IP/route on the internal compose bridge so APP01/DC01
# are only reachable via MS01. Uses a privileged container (docker group)
# instead of host sudo.
set -euo pipefail
NET="${1:-oscp-prep-lab_lab-internal}"

nid=$(docker network inspect -f '{{.Id}}' "$NET")
br="br-${nid:0:12}"

if ! ip link show "$br" >/dev/null 2>&1; then
  echo "bridge $br not found" >&2
  exit 1
fi

docker run --rm --privileged --network host --pid host alpine:3.20 \
  sh -c "ip addr flush dev $br scope global"

if curl -fsS -m 2 http://172.28.20.12/ >/dev/null 2>&1; then
  echo "FAIL host can still reach APP01" >&2
  exit 1
fi
echo "OK  $br flushed; APP01 not reachable from host"
