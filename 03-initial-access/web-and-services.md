# Initial Access: Web & Common Services

## Goal

Turn a network service into a **command execution** or **valid credentials**. OSCP footholds are usually boring-and-reliable, not 0-days.

## Web application playbook

### 1. Map the app

```bash
whatweb http://TARGET
curl -i http://TARGET
feroxbuster -u http://TARGET -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
```

Record:

- Tech stack (PHP, ASP.NET, Tomcat, custom)
- Auth surfaces
- File upload / command features
- Interesting parameters (`?page=`, `?file=`, `?id=`)

### 2. Common web vectors (OSCP depth)

| Vector | What to try | Next step |
|--------|-------------|-----------|
| LFI/RFI | `../../../../etc/passwd`, PHP wrappers | Log poison / SSH keys / configs |
| File upload | Web shell, polyglot, reverse shell | Execute via web path |
| SQLi | Auth bypass, UNION, file read | Creds or RCE (INTO OUTFILE, xp_cmdshell on linked DB) |
| Command injection | `; id`, `| whoami`, `` `id` `` | Reverse shell |
| Default creds | admin/admin, tomcat/tomcat | Panel RCE (manager deploy) |
| Known CVE | Searchsploit version | Edit exploit, understand it |
| Info disclosure | phpinfo, `.git`, backups, `.env` | Creds |

### 3. phpinfo & config leaks

**Common chain:**

1. Directory enum finds `phpinfo.php` / debug pages
2. DB credentials appear in the page
3. Creds work on **MSSQL 1433**
4. Enable `xp_cmdshell` → reverse shell

**Lesson:** Treat every verbose error and info page as a credential source.

### 4. Authenticated RCE patterns

**Authenticated admin panels (generic patterns):**

| Panel type | Typical chain |
|------------|----------------|
| FTP admin / file server UI | Backup leaks hash → crack → script/LUA RCE → reverse shell |
| Usermin / Webmin | Metadata/default creds → command shell feature |
| Hosting panels (e.g. Vesta-class) | SNMP/other leak → case-sensitive login → cron job payload; stage script if inline shell fails |

### 5. Searchsploit workflow

```bash
searchsploit "application name" version
searchsploit -m EXPLOIT_ID   # copy exploit to cwd
# Read, fix RHOST/LHOST, fix version assumptions, test safely
```

Never run a public exploit without reading it.

## Service footholds outside web

### FTP → credentials / webroot

```bash
ftp TARGET
# get backups, use exiftool, strings
exiftool *.pdf
```

### SMB → files / hashes / command exec

```bash
nxc smb TARGET -u user -p pass --shares
nxc smb TARGET -u user -p pass -x 'whoami'
impacket-psexec domain/user:pass@TARGET
impacket-smbexec domain/user:pass@TARGET
impacket-wmiexec domain/user:pass@TARGET
```

Port map for Impacket lateral tools:

| Tool | Typical ports |
|------|----------------|
| psexec.py | 445 |
| smbexec.py | 445 |
| atexec.py | 445 |
| wmiexec.py | 135, 445 (+ dynamic) |
| dcomexec.py | 135, 445 (+ dynamic) |

### WinRM

```bash
evil-winrm -i TARGET -u 'DOMAIN\user' -p 'Password'
evil-winrm -i TARGET -u 'DOMAIN\user' -H 'NTHASH'
```

### SSH

```bash
ssh user@TARGET
ssh -i id_rsa user@TARGET
# crack key passphrase if needed — see password-attacks
```

### MSSQL

See dedicated [08-mssql/attacks.md](../08-mssql/attacks.md).

## Credential-first footholds

Often faster than exploit chains:

```bash
# Spray carefully (lockout awareness in real engagements; lab/exam per rules)
nxc smb TARGETS/24 -u users.txt -p 'Welcome1' --continue-on-success
nxc winrm TARGET -u users.txt -p passwords.txt --continue-on-success
```

Password reuse across:

- Local admin ↔ domain user
- Web app ↔ OS account
- SQL login ↔ Windows login

## Soft skills that win machines

1. **Read error messages** — path disclosure, SQL errors, stack traces.
2. **Change one variable at a time** when testing injection.
3. **Case sensitivity** — usernames on Linux/panels often matter.
4. **History files** — PowerShell history often holds the next password when remote ports are rabbit holes.
5. **Rabbit holes** — open MSSQL with wrong user may be intentional bait.

## Minimal foothold validation

Once you have execution:

```text
1. Who am I? (id / whoami / whoami /all)
2. Where am I? (hostname, ipconfig/ip a)
3. Can I reach Kali? (ping/curl LHOST)
4. Grab local.txt if present
5. Enumerate for privesc — do not stop at foothold
```
