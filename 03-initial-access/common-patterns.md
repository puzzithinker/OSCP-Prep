# Common Initial Access Patterns

Reusable patterns (generic). Match services you actually see — do not force a pattern.

## Pattern A — Info disclosure → service login → RCE

```text
HTTP verbose page / phpinfo / .env / backup
  → database or app credentials
  → MSSQL / MySQL / admin panel
  → command execution feature or xp_cmdshell
  → reverse shell
```

**Enum tips:** directory brute, backup extensions (`.bak`, `.old`, `.zip`), `phpinfo.php`.

## Pattern B — File service → credentials → app RCE

```text
FTP/SMB anonymous or weak auth
  → configs, hashes, documents
  → metadata usernames (ExifTool)
  → crack / reuse password
  → authenticated admin UI RCE
```

**Enum tips:** download everything small; `strings` + `exiftool`; crack fast hashes early.

## Pattern C — UDP / management protocol leak

```text
TCP attack surface noisy or empty
  → UDP scan (SNMP 161, etc.)
  → community string walk
  → cleartext creds or paths
  → panel / SSH / web login
```

**Enum tips:** install MIBs; full walk (`snmpbulkwalk … .`); try common communities.

## Pattern D — Weak or default credentials

```text
Identified app (Tomcat, Jenkins, WordPress, custom)
  → default or spray creds
  → script console / plugin upload / theme edit
  → shell
```

## Pattern E — Public CVE on outdated banner

```text
Version from -sV / headers
  → searchsploit / GitHub PoC
  → read and fix exploit
  → shell
```

**Rule:** never run a PoC you have not read. Fix RHOST/LHOST/paths/versions.

## Pattern F — Credential reuse (fastest lateral)

```text
Password or hash from host A
  → nxc spray host list
  → WinRM/SMB/RDP/SSH on host B
```

Always spray **before** deep exploit work on the next target.

## Pattern G — Assumed-breach AD entry

```text
Provided domain user
  → enum + roast + shares
  → local admin somewhere
  → dump → DA
```

See [AD decision flow](../05-active-directory/decision-flow.md).

## Choosing among patterns

| Observation | Prefer |
|-------------|--------|
| HTTP + interesting dirs | A, D, E |
| FTP/SMB open | B, F |
| Few TCP ports, stuck | C |
| Valid password in loot | F first |
| Domain creds given | G |

## After any foothold

```text
Stabilize shell → proof if present → enum privesc → loot → spray → pivot
```
