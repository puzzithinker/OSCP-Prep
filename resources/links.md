# Resources & Tooling (2026)

## Official OffSec

- [PEN-200 course page](https://www.offsec.com/courses/pen-200/)
- [OSCP Exam Guide](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide)
- [Changes to the OSCP](https://help.offsec.com/hc/en-us/articles/29840452210580-Changes-to-the-OSCP)
- [OffSec CPE / OSCP+ maintenance](https://help.offsec.com/hc/en-us/articles/35366391096596-OffSec-CPE-Program-and-Annual-Maintenance-Handbook)

## Reporting & note-taking (recommended)

| Resource | Use |
|----------|-----|
| [Syslifters/OffSec-Reporting](https://github.com/Syslifters/OffSec-Reporting) | OffSec exam/lab report designs (OSCP+, OSEP, OSWE, …) |
| [SysReptor](https://github.com/Syslifters/sysreptor) | Markdown → PDF pentest reporting platform |
| [SysReptor docs](https://docs.sysreptor.com/) | Install, designs, workflows |
| [OffSec SysReptor signup](https://offsec.sysreptor.com/offsec/signup/) | Free hosted OffSec reporting |

Local guide: [reporting-sysreptor.md](reporting-sysreptor.md)

## Terminal command launcher (recommended)

| Resource | Use |
|----------|-----|
| [arsenal-ng](https://github.com/halilkirazkaya/arsenal-ng) | Fast Go TUI cheatsheet launcher (search, `{{args}}`, globals) |
| [Orange arsenal](https://github.com/Orange-Cyberdefense/arsenal) | Original Python arsenal (legacy) |

Local guide: [arsenal-ng.md](arsenal-ng.md)

## Cheat sheets & methodology

| Resource | Use |
|----------|-----|
| [HackTricks](https://book.hacktricks.xyz/) | Service-by-service playbooks |
| [PayloadsAllTheThings](https://swisskyrepo.github.io/PayloadsAllTheThings/) | Web / injection payloads |
| [GTFOBins](https://gtfobins.github.io/) | Unix sudo/SUID abuse |
| [LOLBAS](https://lolbas-project.github.io/) | Windows living-off-the-land |
| [WADComs](https://wadcoms.github.io/) | AD command recipes |
| [Orange Cyberdefense AD mindmap](https://orange-cyberdefense.github.io/ocd-mindmaps/) | AD attack paths visual |
| [ired.team](https://www.ired.team/) | AD / Kerberos deep dives |
| This repo [cheatsheets/](../cheatsheets/) | Curated OSCP markdown |

## Core tools (install on Kali)

| Tool | Role | Notes |
|------|------|-------|
| **arsenal-ng** | Command search / launch | Exam speed |
| **NetExec (`nxc`)** | SMB/WinRM/LDAP/MSSQL spray & exec | Prefer over CME |
| **Impacket** | psexec, secretsdump, GetUserSPNs, mssqlclient | Essential |
| **evil-winrm** | WinRM shells | Hash + password |
| **BloodHound CE / SharpHound** | AD graph | OSCP-depth paths |
| **chisel** / **ligolo-ng** | Pivoting | Prefer ligolo for TUN |
| **Responder** | LLMNR/NBT-NS (labs) | Know detection impact |
| **Rubeus** | Kerberos (Windows) | Roast, ptt, monitor |
| **mimikatz** / **pypykatz** | Creds | procdump offline often cleaner |
| **PrintSpoofer / GodPotato** | SeImpersonate | |
| **winPEAS / linPEAS / pspy** | Enum | |
| **PowerView / PowerUp / PowerUpSQL** | Windows / SQL | |
| **hashcat / john** | Cracking | Correct modes |
| **feroxbuster / ffuf / gobuster** | Web enum | |
| **autorecon** | Automated recon | Still read output |

### NetExec install (example)

```bash
pipx install git+https://github.com/Pennyw0rth/NetExec
# or Kali package when available
nxc --help
```

## Kerberos notes

- [Tarlogic Kerberos cheatsheet gist](https://gist.github.com/TarlogicSecurity/2f221924fef8c14a1d8e29f3cb5c5c4a)
- Clock sync + DNS to DC are mandatory for `-k` workflows

## Practice platforms

| Platform | Why |
|----------|-----|
| OffSec PEN-200 labs | Closest to exam |
| Proving Grounds Practice | OSCP-like boxes |
| Hack The Box | Windows/AD reps |
| VulnHub | Linux fundamentals |
| GOAD / home AD lab | AD muscle memory |

## What to deprioritize for OSCP 2026

| Topic | Why |
|-------|-----|
| Buffer overflow grinding | Not on exam |
| Full ADCS ESC1–ESC8 mastery | OSEP/CRTO territory |
| Heavy C2 frameworks | Overkill; manual shells preferred |
| AWS course module | Not exam (per OffSec change notes) |
| Mega one-file command dumps | Prefer arsenal-ng + curated sheets |

## Keeping this repo fresh

After each lab:

1. Writeup under `09-lab-writeups/`  
2. Patch a file under `cheatsheets/` if a command was missing  
3. Optionally add a private arsenal-ng YAML action  
4. Practice one finding in SysReptor so report muscle memory stays sharp  
