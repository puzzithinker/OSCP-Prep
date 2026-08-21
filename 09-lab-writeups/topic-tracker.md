# PEN-200 / OSCP Topic Tracker

Check off when you can **do it without notes** on a practice box (not just watched a video).

Legend: `[ ]` todo · `[~]` shaky · `[x]` solid

Full BoK map: [required-knowledge-2026.md](../00-exam/required-knowledge-2026.md)

## Foundations (background)

- [ ] TCP/IP: addressing, subnetting, common protocols
- [ ] Linux admin comfort (users, services, files, networking)
- [ ] Windows admin comfort (users, shares, services, PowerShell basics)
- [ ] Basic AD awareness (domain users/groups/computers concept)
- [ ] Bash and/or Python for small scripts and parsing

## Exam ops

- [ ] Workspace + note structure under pressure
- [ ] Full TCP + service scan workflow
- [ ] Proof screenshots (identity + flag same frame)
- [ ] Control-panel flag submit + original-path `cat`/`type`
- [ ] Report section per host (enum → exploit → privesc → fix)
- [ ] Report package: `OSCP-OS-XXXXX-Exam-Report.pdf` → password-free `.7z` under 200MB
- [ ] Time-boxing / host rotation discipline
- [ ] Metasploit single-target discipline (if used)

## Information gathering

- [ ] Nmap ladder (quick → full → scripts)
- [ ] Web: dirs, vhosts, tech fingerprint
- [ ] SMB: null + auth shares, spidering
- [ ] SNMP / UDP when TCP is thin
- [ ] Metadata (ExifTool), backups, `.git`, configs
- [ ] AutoRecon (or equivalent) **and** reading output

## Initial access — web

- [ ] File upload → web shell / reverse shell
- [ ] LFI → sensitive files / log poison concepts
- [ ] SQLi → data or RCE path
- [ ] Command injection
- [ ] Auth bypass / default creds on panels
- [ ] Public exploit adaptation (read, fix, run)

## Initial access — services

- [ ] FTP enum + weak auth
- [ ] SSH key / password reuse
- [ ] WinRM (evil-winrm password + hash)
- [ ] RDP + PTH considerations
- [ ] MSSQL login + `xp_cmdshell`
- [ ] SMB exec (psexec/wmiexec/nxc)

## Shells & transfer

- [ ] Multi-port reverse shells (443/80/53)
- [ ] Linux TTY upgrade
- [ ] PowerShell download cradles + encoded commands
- [ ] certutil / iwr / SMB file transfer
- [ ] msfvenom exe/aspx/elf/php/msi as needed

## Windows privilege escalation

- [ ] `whoami /priv` triage
- [ ] SeImpersonate → PrintSpoofer/GodPotato
- [ ] Backup Operators / SeBackupPrivilege → SAM dump
- [ ] Service binPath / unquoted path / weak ACL
- [ ] AlwaysInstallElevated
- [ ] Scheduled tasks / startup abuse
- [ ] Credential hunting (history, web.config, autologon)
- [ ] Runas / RunasCs with found passwords

## Linux privilege escalation

- [ ] `sudo -l` + GTFOBins
- [ ] SUID / capabilities
- [ ] Cron / timers / wildcard tar-style abuse
- [ ] Writable scripts executed by root
- [ ] Creds in history, configs, mail
- [ ] PATH hijack concepts
- [ ] Docker/socket group escape (if present)
- [ ] Kernel exploit only when version-matched

## Password attacks

- [ ] Identify hash type
- [ ] hashcat modes: NTLM, NetNTLMv2, Kerberoast, AS-REP
- [ ] john for SSH keys / KeePass / odd formats
- [ ] Spray with NetExec responsibly
- [ ] Build small custom wordlists from loot

## Active Directory

- [ ] DNS + clock for Kerberos
- [ ] Assumed-breach enum as domain user
- [ ] NetExec spray + local admin mapping
- [ ] Kerberoasting end-to-end + crack
- [ ] AS-REP roasting end-to-end + crack
- [ ] Pass-the-hash lateral
- [ ] Pass-the-ticket / ccache basics
- [ ] secretsdump host + DCSync-class DA dump
- [ ] BloodHound basic path reading
- [ ] SYSVOL/scripts credential hunting
- [ ] Full chain: user → local admin → DA → DC proof

## MSSQL

- [ ] Connect (SQL + Windows auth + Kerberos)
- [ ] Role checks / impersonation
- [ ] xp_cmdshell enable + shell
- [ ] Linked servers / OPENQUERY / nested EXEC
- [ ] xp_dirtree coerce for NTLM capture/relay concept
- [ ] PowerUpSQL link crawl (optional)

## Pivoting

- [ ] Identify dual-homed host + routes
- [ ] chisel reverse SOCKS + proxychains
- [ ] ligolo-ng TUN + routes
- [ ] SSH -D / -L / -R (port redirect + dynamic)
- [ ] Course-level advanced / DPI tunneling concepts (awareness + lab practice)
- [ ] Scan and attack internal hosts through tunnel
- [ ] Double-hop reverse shell via pivot

## Metasploit (within exam policy)

- [ ] msfvenom payloads (exe/elf/aspx/php as needed)
- [ ] multi/handler listeners
- [ ] One-host exploit/post/Meterpreter workflow (if used)
- [ ] Habit: never pivot multi-host via MSF on exam

## Modern tooling

- [ ] NetExec instead of CrackMapExec reflexes
- [ ] Impacket suite fluency
- [ ] Prefer procdump/offline parse when mimikatz is painful

## Stretch (not required for OSCP depth)

- [ ] ADCS ESC basics (awareness)
- [ ] Constrained/unconstrained delegation attacks
- [ ] Advanced coercion (PetitPotam, etc.)
- [ ] Custom C2
- [ ] AWS course module (course only — not exam BoK as of public FAQ)
- [ ] Buffer overflows (removed from exam)

### Suggested study order (OffSec 12-week style)

1. Web enum/exploit + public exploits  
2. Password attacks  
3. Win + Linux privesc  
4. Port redirect / SSH / advanced tunneling  
5. Metasploit (limited)  
6. AD enum → auth attacks → lateral  

---

## Local Docker range (optional offline reps)

See [labs/docker/README.md](../labs/docker/README.md). Tick when you can finish **without** `SPOILERS.md`:

- [ ] harbor: upload foothold + cron root
- [ ] ledger: LFI → SSH + sudo find
- [ ] catalog: manual SQLi → SUID PATH
- [ ] chain: assumed-breach MS01 → pivot → APP01 loot → DC01 proof
- [ ] Proof screenshots (hostname + id + flag) on each

Live platforms (PEN-200 / PG / HTB / GOAD): [practice-labs-2026.md](../resources/practice-labs-2026.md)

## Practice log (optional)

| Date | Box / lab | Topics practiced | Result |
|------|-----------|------------------|--------|
| | | | |
| | | | |
| | | | |

## Weekly review prompts

1. Which checkbox stayed `[~]` after real hands-on?  
2. Which rabbit hole cost the most time?  
3. What command was missing from the cheatsheet?  
4. Did I document loot for credential reuse?  
