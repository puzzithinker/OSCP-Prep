# Information Gathering & Enumeration

Enumeration is the OSCP skill that separates pass from fail. Most “hard” machines are **easy exploits after slow recon**.

## Mindset

- Ports are hypotheses, not answers.
- Every service has **files, auth, and trust** — hunt all three.
- Document *negative* results (“null session denied”) so you do not re-test blindly.

## Nmap patterns (exam-ready)

```bash
# Quick overview
nmap -f -oG scans/quick.gnmap TARGETS
nmap --open -Pn -p- -sV -sC -T4 -oA scans/full TARGET

# Aggressive when time allows / host is interesting
nmap -p0- -v -A -T4 -oA scans/aggressive TARGET

# Script categories (targeted)
nmap -Pn -p 445 --script smb-enum-shares,smb-enum-users TARGET
nmap -Pn -p 80,443 --script http-enum,http-title,http-methods TARGET
nmap -Pn -sU -p 161 --script snmp-info TARGET
```

### Parsing open ports quickly

```bash
# From -oG
grep '/open/' scans/full.gnmap

# From -oN / XML use whatever you prefer; keep a one-liner habit
```

## Service-by-service checklist

### FTP (21)

```bash
ftp TARGET
# try anonymous
nmap -p21 --script ftp-anon,ftp-syst TARGET
```

Hunt:

- Backups, configs, PDFs (ExifTool authors → username candidates)
- Writable dirs for web shells if FTP maps to webroot

**Pattern:** FTP backups → ExifTool authors/usernames → weak or reused panel credentials → authenticated RCE.

### SSH (22)

```bash
ssh user@TARGET
# check banner / algorithms if needed
nmap -p22 -sV TARGET
```

Hunt: reused passwords, SSH keys from other hosts, username enum only if relevant.

### SMTP (25/587)

```bash
smtp-user-enum -M VRFY -U users.txt -t TARGET
```

### DNS (53)

```bash
dig axfr @TARGET domain.local
dnsrecon -d domain.local -n TARGET
```

### HTTP/HTTPS (80/443/8xxx)

```bash
# Tech fingerprint
whatweb http://TARGET
httpx -u http://TARGET -title -tech-detect

# Directories (pick one primary tool and stick to it)
feroxbuster -u http://TARGET -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
gobuster dir -u http://TARGET -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
nikto -h http://TARGET
```

Always check:

| Path idea | Why |
|-----------|-----|
| `/robots.txt`, `/sitemap.xml` | Hidden paths |
| `/phpinfo.php`, `/info.php` | Creds, paths, versions |
| `/backup`, `/old`, `/dev`, `/.git` | Source / DB dumps |
| Default CMS paths | Known vulns |
| Virtual hosts | Extra apps |

```bash
# Vhost brute
ffuf -u http://TARGET -H "Host: FUZZ.domain.local" -w subdomains.txt -fs SIZE
```

### SMB (139/445)

```bash
# NetExec (prefer over CrackMapExec)
nxc smb TARGET
nxc smb TARGET -u '' -p '' --shares
nxc smb TARGET -u users.txt -p 'Password123' --continue-on-success
nxc smb TARGET -u user -p pass -M spider_plus

# Classic
smbclient -L //TARGET -N
smbclient -L //TARGET/ -U 'USER%PASS'
smbmap -H TARGET
enum4linux-ng TARGET
```

#### smbclient multi-get (download whole share)

```bash
smbclient //TARGET/SHARE -U 'USER%PASS'
# inside smbclient:
mask ""
recurse ON
prompt OFF
mget *
```

```bash
# SYSVOL / scripts often hold passwords
smbclient //DC/SYSVOL -U 'USER%PASS'
```

### LDAP / AD (389/636/3268)

```bash
nxc ldap TARGET -u USER -p PASS --users
nxc ldap TARGET -u USER -p PASS --groups
ldapsearch -x -H ldap://DC -D 'DOMAIN\user' -w 'pass' -b "DC=domain,DC=local"
```

### WinRM (5985/5986)

```bash
nxc winrm TARGET -u USER -p PASS
evil-winrm -i TARGET -u USER -p PASS
evil-winrm -i TARGET -u USER -H NTHASH
```

### MSSQL (1433)

```bash
nxc mssql TARGET -u sa -p pass
impacket-mssqlclient DOMAIN/user:pass@TARGET -windows-auth
```

See [08-mssql/attacks.md](../08-mssql/attacks.md).

### RDP (3389)

```bash
nxc rdp TARGET -u USER -p PASS
xfreerdp /v:TARGET /u:USER /p:PASS /cert:ignore +clipboard
# Pass-the-hash (Restricted Admin / DisableRestrictedAdmin)
xfreerdp /v:TARGET /u:USER /pth:NTHASH /cert:ignore +clipboard
```

### SNMP (UDP 161)

**Pattern:** Noisy TCP ports can be rabbit holes; UDP (especially SNMP 161) is often the real entry.

```bash
sudo apt install snmp snmp-mibs-downloader   # once
sudo download-mibs
# ensure mibs are not disabled in /etc/snmp/snmp.conf

# community strings
onesixtyone -c /usr/share/seclists/Discovery/SNMP/common-snmp-community-strings.txt TARGET
snmpwalk -v2c -c public TARGET
# Leading dot / .1 pulls from root of MIB tree — often the difference between empty and gold
snmpwalk -v2c -c public TARGET .1
snmpbulkwalk -v2c -c public TARGET .
```

#### Useful OIDs (Windows / generic)

| OID | Often returns |
|-----|----------------|
| `1.3.6.1.2.1.1.5` | sysName |
| `1.3.6.1.4.1.77.1.2.25` | Windows user accounts (legacy) |
| `1.3.6.1.2.1.25.4.2.1.2` | Running processes (HOST-RESOURCES) |
| `1.3.6.1.2.1.25.6.3.1.2` | Installed software |
| `1.3.6.1.4.1.77.1.2.3.1.1` | Windows share names (legacy) |
| `nsExtendObjects` | Extend scripts / command output (Linux net-snmp) |

```bash
snmpwalk -c public -v1 TARGET 1.3.6.1.4.1.77.1.2.25
snmpwalk -c public -v1 TARGET 1.3.6.1.2.1.25.4.2.1.2
snmpwalk -v2c -c public TARGET nsExtendObjects
```

Hunt: usernames, process paths, network interfaces, **cleartext credentials** in descriptions.

### NFS (2049)

```bash
showmount -e TARGET
sudo showmount -e TARGET
# mount export (check no_root_squash for privesc)
mkdir -p /mnt/nfs
sudo mount -t nfs TARGET:/export /mnt/nfs
# NFSv4 example
sudo mount -t nfs -o vers=4,nolock TARGET:/export /mnt/nfs
cat /etc/exports   # on a Linux foothold — list exports + options
```

If `no_root_squash`: from attacker, create SUID binary as root on the share, execute as low-priv on the NFS server.

## Web content & metadata

```bash
exiftool file.pdf
strings backup.zip | less
binwalk firmware.bin
```

Authors, software versions, internal hostnames, and emails become:

- Username wordlists
- Password spray candidates
- Pivot map clues

## Credential wordlist hygiene

As you enum, maintain:

```text
users.txt     # found + common + domain conventions
passwords.txt # found + seasonal + company-related
hashes.txt    # with mode tags
loot.md       # free-form secrets
```

Username patterns that often work in labs/exams:

```text
admin, administrator, support, backup
firstname.lastname, flast, firstl
service accounts: sql_svc, backup_svc, iis_app
```

## BloodHound / AD recon (high level)

When you have any domain user:

```bash
# From Linux (example collectors vary by version)
bloodhound-python -d DOMAIN -u USER -p PASS -ns DC_IP -c All
# Or SharpHound from a domain-joined foothold
```

OSCP-depth questions BloodHound answers:

- Who has local admin where?
- Kerberoastable users?
- Paths to Domain Admins? (often shorter than you think in exam AD)

## Rabbit holes vs gold

| Signal | Often gold | Often rabbit hole |
|--------|------------|-------------------|
| Single weird high port + weak app | Yes | |
| 20 open ports, no versions of interest | Maybe UDP / web vhosts | Chasing every CVE |
| Credentials in history / configs | Yes | Blind SQLi for hours with no data |
| Outdated kernel + “high probable” | Sometimes | First action without misconfig enum |

## Proof of recon completion (personal bar)

Before claiming “nothing on this host”:

- [ ] Full TCP ports
- [ ] Service versions on all open TCP
- [ ] Web directories on all HTTP(S)
- [ ] SMB shares (auth + unauth)
- [ ] At least considered UDP (SNMP/DNS)
- [ ] Searched discovered files for secrets
- [ ] Tried credential reuse from other hosts
