# Active Directory Enumeration

## OSCP AD mental model (2026)

The exam AD set is **assumed breach**: you get domain credentials. Your job:

```text
Use creds → map domain → find more creds / misconfigs →
lateral movement → privilege → Domain Admin / DC proof
```

OffSec AD is typically **fundamentals done carefully**, not advanced ADCS forest wars.

## DNS / time / Kerberos prep (Linux attacker)

Kerberos is picky. Treat these as non-negotiable:

```bash
# Point DNS at DC
echo "DC_IP dc01.domain.local domain.local" | sudo tee -a /etc/hosts
# or systemd-resolved / resolv.conf to DC

# Clock skew kills TGT requests
timedatectl set-ntp 0
sudo ntpdate DC_IP

# Domain case sensitivity in tools — prefer correct case, avoid wrong quoting
export DOMAIN=DOMAIN.LOCAL
```

```bash
# Verify
nslookup dc01.domain.local
nxc smb DC_IP -u user -p pass
```

## First authentication checks

```bash
# NetExec (prefer over CrackMapExec in 2025+)
nxc smb 172.16.x.0/24 -u 'user' -p 'pass' --continue-on-success
nxc smb targets.txt -u 'user' -H 'NTHASH' --continue-on-success
nxc winrm TARGET -u 'user' -p 'pass'
nxc mssql TARGET -u 'user' -p 'pass' -d DOMAIN

# Who is admin where? (Pwn3d!)
nxc smb targets.txt -u 'user' -p 'pass'
```

## Manual Windows enum (PowerView / built-ins)

```powershell
# Domain
[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
net user /domain
net group /domain
net group "Domain Admins" /domain
nltest /dclist:
nltest /domain_trusts
```

PowerView classics:

```powershell
Import-Module .\PowerView.ps1
Get-NetDomain
Get-NetDomainTrust
Get-NetUser | select cn,samaccountname,description,pwdlastset
Get-NetComputer
Get-NetComputer -Unconstrained
Get-NetUser -SPN
Get-NetGroup
Get-NetGroupMember -GroupName "Domain Admins"
Get-NetShare
Find-LocalAdminAccess
```

## Linux enum (Impacket / NetExec / ldap)

```bash
impacket-GetADUsers domain/user:pass -all -dc-ip DC
impacket-GetUserSPNs domain/user:pass -dc-ip DC -request
impacket-GetNPUsers domain/user:pass -dc-ip DC -usersfile users.txt -format hashcat

nxc ldap DC -u user -p pass --users
nxc ldap DC -u user -p pass --groups
nxc ldap DC -u user -p pass --bloodhound --collection All
```

### pywerview

Useful commands:

```bash
pywerview get-netdomain -u USER -t dc.domain.local -p PASS
pywerview get-netdomaintrust -u USER -t dc.domain.local -p PASS
pywerview get-netcomputer -u USER -d domain.local -t dc.domain.local -p PASS
pywerview get-netcomputer -u USER -d domain.local -t dc.domain.local -p PASS --unconstrained
pywerview get-netcomputer -u USER -d domain.local -t dc.domain.local -p PASS -spn '*'
pywerview get-netgroup -u USER -d domain.local -t dc.domain.local -p PASS
pywerview get-netgroupmember -u USER -d domain.local -t dc.domain.local -p PASS --groupname 'GroupName'
pywerview get-netuser -u USER -d domain.local -t dc.domain.local -p PASS
pywerview get-netuser -u USER -d domain.local -t dc.domain.local -p PASS --spn
# --hashes when password unknown
```

**Tip:** Diff domain groups against a list of default AD groups to spot custom privileged groups quickly.

## BloodHound queries (starter)

```cypher
// All computers
MATCH (u:Computer) RETURN u.name

// Nodes with outgoing ACL permissions
MATCH (n)-[r]->(g) WHERE r.isacl = true RETURN DISTINCT n.name

// Shortest paths to Domain Admins (classic)
MATCH p=shortestPath((u:User {name:'USER@DOMAIN.LOCAL'})-[*1..]->(g:Group {name:'DOMAIN ADMINS@DOMAIN.LOCAL'})) RETURN p
```

## What to collect into loot table

| Item | Example |
|------|---------|
| Domain / forest / trusts | corp.local → child |
| DCs / DNS | dc01 172.16.x.x |
| Users + descriptions | “password is …” in description |
| SPNs | Kerberoast candidates |
| AS-REP roastable | DONT_REQ_PREAUTH |
| Local admin mapping | user → hosts |
| Shares | scripts, backup, IT |
| Sessions | where DA is logged on |
| MSSQL links | double-hop SQL |

## SMB signing / relay recon

```bash
nxc smb 172.16.x.0/24 --gen-relay-list relay.txt
# Hosts with signing:False are relay candidates in appropriate attack scenarios
```

## Shares & files

```bash
nxc smb TARGET -u user -p pass --shares
nxc smb TARGET -u user -p pass -M spider_plus
smbclient //TARGET/Share -U 'domain/user%pass'
```

Always open:

- `\\dc\sysvol` / NETLOGON scripts
- backup shares
- user home directories
- `web.config`, `unattend.xml`, scripts with passwords

## PowerShell history on domain hosts

Your AD lab note called this out explicitly (PEN-200 Windows privesc “Information Goldmine”):

```powershell
type (Get-PSReadlineOption).HistorySavePath
# Often: C:\Users\<user>\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
```

Cleartext passwords, `Enter-PSSession`, and `net use` lines appear here.

## Unconstrained / constrained delegation (awareness)

```bash
# Computers with unconstrained
nxc ldap DC -u user -p pass -M adcs  # various modules; or
impacket-findDelegation domain/user:pass
```

OSCP may not require full delegation attack chains, but **recognizing** unconstrained systems is useful if you land high privileges there.

## Enumeration output hygiene

Keep a living file:

```markdown
## Domain: OSCPEXAM.LOCAL
- DC: dc01 / 172.16.x.100
- Creds: support / ...
- Local admin on host-A: ...
- Roastable: ...
- Next step: ...
```

Update after every successful auth — AD is a **state machine**, not a single exploit.
