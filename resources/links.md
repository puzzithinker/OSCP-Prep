# Resources & Tooling (2026)

## Official OffSec

- [PEN-200 course page](https://www.offsec.com/courses/pen-200/)
- [OSCP Exam Guide](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide) (OSCP+ format, scoring, tools)
- [OSCP Exam FAQ](https://help.offsec.com/hc/en-us/articles/4412170923924-OSCP-Exam-FAQ)
- [Changes to the OSCP](https://help.offsec.com/hc/en-us/articles/29840452210580-Changes-to-the-OSCP) (Nov 2024+ framework)
- [OSCP Exam Changes](https://help.offsec.com/hc/en-us/articles/29865898402836-OSCP-Exam-Changes)
- [PEN-200 onboarding](https://help.offsec.com/hc/en-us/articles/4406841351316-PEN-200-Onboarding-A-Learner-Introduction-Guide-to-the-OSCP)
- [PEN-200 FAQ](https://help.offsec.com/hc/en-us/articles/12483872278932-PEN-200-FAQ)
- [12-week PEN-200 learning plan](https://help.offsec.com/hc/en-us/articles/15541765522196-OffSec-PEN-200-Learning-Plan-12-Week)
- [PEN-200 2023 update blog](https://www.offsec.com/blog/pen-200-2023/) (module framing; BOF removal era)
- [OffSec CPE / OSCP+ maintenance](https://help.offsec.com/hc/en-us/articles/35366391096596-OffSec-CPE-Program-and-Annual-Maintenance-Handbook)
- Report upload: [upload.offsec.com](https://upload.offsec.com)

Local BoK map: [required-knowledge-2026.md](../00-exam/required-knowledge-2026.md)

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

## Community OSCP collections (sources for this repo)

| Resource | Use |
|----------|-----|
| [0xsyr0/OSCP](https://github.com/0xsyr0/OSCP) | Large maintained OSCP+ cheatsheet (commands, tools, links) |
| [OlivierLaflamme/Cheatsheet-God](https://github.com/OlivierLaflamme/Cheatsheet-God) | Topic cheatsheets (shells, transfer, SQLi, pivot, …) |

How we mined them (no full mirror): [community-sources.md](community-sources.md)

## Cheat sheets & methodology

| Resource | Use |
|----------|-----|
| [HackTricks](https://book.hacktricks.xyz/) | Service-by-service playbooks |
| [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) | Web / injection payloads |
| [Tib3rius SQLi cheatsheet](https://tib3rius.com/sqli.html) | Manual SQL injection |
| [GTFOBins](https://gtfobins.github.io/) | Unix sudo/SUID abuse |
| [LOLBAS](https://lolbas-project.github.io/) | Windows living-off-the-land |
| [WADComs](https://wadcoms.github.io/) | AD command recipes |
| [Orange Cyberdefense AD mindmap](https://orange-cyberdefense.github.io/ocd-mindmaps/) | AD attack paths visual |
| [ired.team](https://www.ired.team/) | AD / Kerberos deep dives |
| [DefaultCreds-cheat-sheet](https://github.com/ihebski/DefaultCreds-cheat-sheet) | Default credentials |
| [SecLists](https://github.com/danielmiessler/SecLists) | Wordlists / LFI lists |
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

## Practice platforms (2026)

Deep dive (what still exists, named boxes, sequence): **[practice-labs-2026.md](practice-labs-2026.md)** · local range: **[labs/docker](../labs/docker/README.md)**

| Platform | Why |
|----------|-----|
| OffSec PEN-200 labs + challenge labs | Closest to exam; OSCP A/B/C are exam replicas |
| [Proving Grounds Practice](https://www.offsec.com/products/proving-grounds/) | OffSec Windows/Linux, retired OSCP+ exam labs, $19/mo |
| PG Play | Free Linux (VulnHub community), 3h cap |
| [LainKusanagi OSCP-like](https://docs.google.com/spreadsheets/d/18weuz_Eeynr6sXFQ87Cd5F0slOj9Z6rt) | Grounded PG/HTB/THM list (drops over-hard boxes) |
| [TJ Null / NetSecFocus v3](https://docs.google.com/spreadsheets/d/1dwSMIAPIam0PuRBkCiDI88pU3yzrqqHkDtBngUHNCw8) | Live OSCP+ spreadsheet; [0xdf mapping](https://0xdf.gitlab.io/cheatsheets/offsec) |
| Hack The Box + Pro Labs (Dante, Zephyr) | Volume + AD/pivot networks |
| [GOAD](https://github.com/Orange-Cyberdefense/GOAD) / [Ludus](https://docs.ludus.cloud/) | Home Windows AD |
| VulnHub | Linux VMs; many also on PG Play |
| This repo Docker range | Offline Linux standalones + assumed-breach chain |

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
