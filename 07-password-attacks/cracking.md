# Password Attacks & Hash Cracking

## Philosophy

1. **Reuse found passwords** before cracking
2. Crack with the **right mode**
3. Wordlists: rockyou → custom (company, seasons, found strings)
4. Rules for near-misses (`best64`, `rockyou-30000`)

## Identify the hash

```bash
hashid 'hash_string'
hashcat --example-hashes | less
```

## Hashcat modes (OSCP-relevant)

| Type | Mode | Notes |
|------|------|-------|
| NTLM | 1000 | SAM dumps |
| NetNTLMv2 | 5600 | Responder / coerced auth |
| Kerberoast (TGS-REP) | 13100 | GetUserSPNs output |
| AS-REP | 18200 | GetNPUsers |
| Kerberos etype variants | check hash format | |
| MySQL | 200 / 300 | version-dependent |
| bcrypt | 3200 | slow |
| Ansible vault | 16900 | |
| KeePass | 13400 | .kdbx |
| SSH private key | via ssh2john | then john/hashcat |

### Corrected Kerberoast mode

Older notes said `hashcat -m 100` for Kerberoast — that is **not** the modern TGS format. Use:

```bash
hashcat -m 13100 tgs.txt /usr/share/wordlists/rockyou.txt
```

### NetNTLMv2

```bash
hashcat -m 5600 hash.txt wordlist.txt
```

### NTLM

```bash
hashcat -m 1000 ntlm.txt wordlist.txt -r /usr/share/hashcat/rules/best64.rule
```

### AS-REP

```bash
hashcat -m 18200 asrep.txt wordlist.txt
```

## John the Ripper

```bash
# Kerberoast
john --format=krb5tgs --wordlist=wordlist.txt tgs.txt

# SSH key
ssh2john id_rsa > ssh.hash
john --wordlist=/usr/share/wordlists/rockyou.txt ssh.hash

# KeePass
keepass2john vault.kdbx > keepass.hash
john --wordlist=rockyou.txt keepass.hash

# Ansible vault
ansible2john vault.yml > ansible.hash
hashcat -m 16900 ansible.hash wordlist.txt
# or after crack:
cat password.txt | ansible-vault decrypt vault.yml
```

## Online / offline helpers

- CrackStation for **fast non-sensitive lab** hashes only
- Never submit real exam/client hashes to public services

## Wordlist generation

```bash
# Pattern
crunch 6 6 -t Lab%%% > wordlist.txt

# From site scrape / loot
cewl http://TARGET -w cewl.txt
```

## Spraying vs cracking

| Approach | When |
|----------|------|
| Spray 1–2 passwords many users | Common corp passwords |
| Crack offline hashes | Roasting, SAM, responder |
| Credential stuffing | Password found on host A tried everywhere |

```bash
nxc smb targets.txt -u users.txt -p 'Password123!' --continue-on-success
```

## Post-crack hygiene

```text
password → try:
  - SMB / WinRM / RDP / SSH / MSSQL / web login
  - Same user other hosts
  - Local Administrator reuse
  - Domain user with local admin
```

Update loot table immediately when a crack succeeds.

## Performance tips

```bash
hashcat -m 13100 tgs.txt wordlist.txt -w 3 --status
# GPU if available; exam VM may be CPU-only — start crack early, work in parallel
```

## Common OSCP crack targets

1. Kerberoast TGS  
2. AS-REP  
3. Local SAM NTLM after Backup Operators / SYSTEM  
4. NetNTLMv2 from forced auth  
5. Application hashes (MD5/SHA) from SQLite/web DB (your AD lab support hash)  
6. SSH key passphrases  
7. KeePass databases found in user folders
