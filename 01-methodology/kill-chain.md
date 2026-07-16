# Penetration Testing Methodology (OSCP-focused)

## Overview

OSCP rewards a **repeatable process**, not memorized one-liners. Every machine — standalone or AD — follows the same loop:

```
Scope → Enumerate → Analyze → Exploit → Post-exploit → Document → Expand
```

## Phase 0 — Workspace setup

Before any scan:

```bash
mkdir -p ~/exam/{scans,loot,screenshots,notes,tools,payloads}
cd ~/exam
# fix VPN, note tun0 IP
ip -br a
```

**Conventions that save hours:**

| Habit | Why |
|-------|-----|
| One folder per target IP | Fast lookup under pressure |
| Always `-oA` nmap outputs | Re-parse without re-scan |
| Loot table (user / secret / where found / where tried) | Credential reuse is half of AD |
| Screenshot as you go | Report is graded |

## Phase 1 — Information gathering

### Scope definition

Write down:

- In-scope CIDRs / host list
- Provided credentials (AD assumed breach)
- Your attack IP and listening ports plan (443, 80, 53, 8443, …)

### Scanning ladder

Do **not** jump to aggressive full scans only. Ladder:

1. **Host discovery** (if needed)
2. **Quick TCP** — top ports / fast overview
3. **Full TCP** — all ports (`-p-`) on live hosts
4. **Service/version + scripts** on discovered ports
5. **UDP** selectively (SNMP 161, DNS 53, TFTP, …) when TCP is thin

Example ladder:

```bash
# Quick map
nmap -Pn -T4 --top-ports 1000 -oA scans/quick TARGET

# Full ports (exam classic)
nmap -Pn -p- -T4 --min-rate 2000 -oA scans/full TARGET

# Deep on open ports only
nmap -Pn -sV -sC -p $(ports_from_full) -oA scans/services TARGET

# UDP (when justified)
nmap -Pn -sU --top-ports 50 -oA scans/udp TARGET
```

**AutoRecon** is excellent for coverage if allowed in your workflow:

```bash
sudo autorecon TARGET --dirbuster.wordlist /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
```

Still **read** the output — tools find doors; you walk through them.

## Phase 2 — Service-centric analysis

For each open port, answer:

1. What software / version?
2. Default creds or known CVEs?
3. Auth surface (login forms, SMB null, anonymous FTP)?
4. File disclosure / backup / metadata?
5. Can this talk **out** (egress) for reverse shells?

Build a mini attack tree per host:

```text
80/http → /partner → sqlite dump → hash → crack → SSH
445/smb → shares → configs → creds → WinRM
1433/mssql → xp_cmdshell → shell → SeImpersonate → SYSTEM
```

## Phase 3 — Exploitation

Rules of engagement for OSCP-style work:

- Prefer **public** exploits you understand and can edit
- Fix broken offsets / paths yourself — do not paste-and-pray forever
- Stabilize the shell before privesc rabbit holes
- One solid foothold beats three half-shells

After shell:

```bash
# Linux TTY upgrade (classic)
python3 -c 'import pty; pty.spawn("/bin/bash")'
# Ctrl-Z
stty raw -echo; fg
export SHELL=bash TERM=xterm-256color
```

## Phase 4 — Privilege escalation

Mindset: **misconfiguration first**, exotic kernel last.

### Windows order of operations

1. `whoami /all` — privileges (SeImpersonate, SeBackup, …)
2. Network / domain membership
3. Running services & unquoted paths / weak ACLs
4. Scheduled tasks, AlwaysInstallElevated
5. Credential files, PSReadLine history, web configs
6. Automated enum (winPEAS, PowerUp) after manual pass

### Linux order of operations

1. `id`, `sudo -l`, groups
2. SUID/SGID, capabilities
3. Cron / timers / writable scripts
4. Credentials in env, history, configs
5. Containers / Docker socket
6. Kernel only when version + exploit reliability are clear

## Phase 5 — Post-exploitation & lateral movement

Loot checklist:

| Category | Examples |
|----------|----------|
| Flags | local.txt, proof.txt |
| Creds | SAM/SYSTEM, lsass, .kdbx, web configs, history |
| Tokens / tickets | Kerberos ccache/kirbi |
| Recon | hosts file, ARP, routes, domain trusts |
| Persistence (lab only) | Not required for OSCP flags — clean up |

AD loop:

```text
Creds → spray / auth test → enumerate (LDAP, shares, SPNs) →
attack (roast, relay if in scope of technique) → new host → loot → repeat → DA
```

## Phase 6 — Documentation (report-grade)

For each host, capture:

1. **Service enumeration table** (IP, ports)
2. **Initial foothold** — vulnerability, steps, commands, screenshot
3. **Privilege escalation** — same structure
4. **Flag contents** + hostname/whoami proof
5. **Fix recommendation** (high-level is enough)

A solid report structure:

- High-level summary + recommendations
- Methodology
- Per-host walkthrough with figures
- Appendix of flag hashes

## Anti-patterns (time killers)

| Anti-pattern | Better approach |
|--------------|-----------------|
| Full auto-scan only, no reading | Read every interesting service banner |
| Kernel exploit as first try | Enumerate misconfigs first |
| Ignoring rabbit holes after 2h | Time-box and rotate |
| No loot table | Credential reuse is free shells |
| One reverse shell port only | Pre-stage 443/80/53/8080 listeners |
| Fancy AD theory on exam | Creds → access → more creds |

## Exam-day time rhythm (suggested)

| Window | Focus |
|--------|-------|
| 0–1h | Workspace, full recon on all targets |
| 1–8h | AD assumed-breach chain + pivot setup |
| 8–16h | Standalone footholds / partials |
| 16–20h | Hard privescs, revisit parked hosts |
| 20–23h45 | Flag hygiene, screenshots, cleanup notes |
| +24h | Report polish and submission |

## Continuous improvement loop (labs)

After each machine write:

1. What enumeration miss cost time?
2. What credential was underused?
3. Which command belongs in the cheatsheet?
4. Add 3–5 lines to the relevant concept page in this repo.
