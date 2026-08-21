# OSCP / OSCP+ Exam Overview (2026)

## Certification landscape

Since **1 November 2024**, OffSec ships two related credentials when you pass the practical exam associated with PEN-200:

| Credential | Validity | Notes |
|------------|----------|--------|
| **OSCP** | Lifetime (brand) | The name recruiters still search for |
| **OSCP+** | 3 years | Renewable via CPE program, recert exam, or another qualifying OffSec exam |

The hands-on exam format itself is stable into 2026: long practical engagement, professional report, heavy AD weighting, **no bonus points**.

Official references:

- [OSCP Exam Guide](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide)
- [OSCP Exam FAQ](https://help.offsec.com/hc/en-us/articles/4412170923924-OSCP-Exam-FAQ)
- [Changes to the OSCP](https://help.offsec.com/hc/en-us/articles/29840452210580-Changes-to-the-OSCP)

Study map of required knowledge (foundations → domains → tools → report): **[required-knowledge-2026.md](required-knowledge-2026.md)**

## Timing

| Phase | Duration |
|-------|----------|
| Active testing | **23 hours 45 minutes** |
| Report writing | **24 hours** after exam ends |
| Pass score | **70 / 100** |

Proctoring, ID checks, and room rules apply. Read the exam guide before exam day so connectivity and proctoring are not surprises.

## Machine structure and scoring

### Standalone machines (60 points)

3 independent hosts × **20 points** each:

- **10** — initial access (`local.txt` / low-priv foothold)
- **10** — privilege escalation (`proof.txt` / admin-root)

### Active Directory set (40 points)

One set of **3 machines** (typical pattern: client/app host → intermediate → domain controller):

| Machine | Points (typical guide wording) |
|---------|--------------------------------|
| Machine #1 | 10 |
| Machine #2 | 10 |
| Machine #3 | 20 |

**Assumed breach:** For the AD portion you receive **username + password**. The skill under test is what you do with a foothold in a domain — enumerate, reuse credentials, move laterally, escalate to domain admin / DC control — not cold-start external recon of the forest.

### Bonus points

**Removed** as of Nov 2024. Lab report / course exercise bonus no longer softens a miss on AD.

## Ways to hit 70

Examples aligned with public exam-guide / FAQ style breakdowns:

| Path | Math |
|------|------|
| Full AD + three `local.txt` | 40 + 30 = **70** |
| Full AD + two `local.txt` + one `proof.txt` | 40 + 20 + 10 = **70** |
| **20** AD + three `local.txt` + two `proof.txt` | 20 + 30 + 20 = **70** |
| **10** AD + three fully completed standalones | 10 + 60 = **70** |

**Practical strategy for most candidates:**

1. **Secure the AD set first** (40). It is the largest single block and is designed as a chain.
2. Then farm **standalone local.txt** flags for partial credit.
3. Escalate standalones only when the path is clear — do not burn hours on one rabbit hole.

Full time models: [scoring-strategy.md](scoring-strategy.md). Skill map: [required-knowledge-2026.md](required-knowledge-2026.md).

## Background expectations (not formal prereqs)

OffSec expects comfort with:

- TCP/IP addressing, subnetting, common protocols/services  
- Hands-on Windows and Linux administration + basic AD awareness  
- Bash and/or Python scripting  

## What is *not* on the exam

| Topic | Status |
|-------|--------|
| Buffer overflow | Removed with 2023 PEN-200 revision — still out of exam BoK in 2026 |
| Advanced ADCS / forest trusts / complex delegation chains | Beyond typical OSCP depth (great for OSEP/CRTO, not required here) |
| AWS module | Present in course material; **not exam content** per public FAQ / change notes (re-check guide near exam day) |

## What *is* heavily weighted

- Deep **enumeration** (web, SMB, LDAP, WinRM, MSSQL, history files, shares)
- **Credential hunting** and reuse
- **Windows + Linux privilege escalation** fundamentals
- **Active Directory authentication attacks** at OSCP depth: password spray, AS-REP roast, Kerberoast, PTH/PTT, secrets dump, DCSync-class domain dominance
- **Pivoting / tunneling** (SSH, port redirect, SOCKS/TUN; course also covers tunneling through DPI)
- **Professional report** with reproducible steps and proof screenshots

## Metasploit and tool policy (mind the limits)

Default training habit: **manual** exploitation and shells. Confirm live rules in the exam guide.

| Category | Working mental model |
|----------|----------------------|
| `msfvenom` / `multi/handler` | Broadly usable for payloads and listeners |
| Auxiliary / Exploit / Post + Meterpreter | Only against **one** chosen target (locked on first use); no multi-host pivot *via* MSF |
| Commercial tools | e.g. Metasploit Pro, Burp Pro — prohibited |
| Auto-exploit / mass scanners | e.g. SQLmap, mass vuln scanners — prohibited |
| AI / LLMs | Direct prompt access during exam — prohibited |
| Common allowed examples | Nmap/NSE, Nikto, Burp Free, BloodHound CE, Impacket, Mimikatz, evil-winrm, Rubeus, Responder without poisoning/spoofing |

Allowed lists are non-exhaustive; prefer techniques taught in PEN-200.

## Report packaging (exam deliverable)

| Item | Requirement |
|------|-------------|
| Filename | `OSCP-OS-XXXXX-Exam-Report.pdf` |
| Archive | Password-free `.7z`, under **200 MB** |
| Upload | upload.offsec.com within **24h** of exam end |
| Proofs | Submitted in control panel **before** exam ends; screenshots from interactive shell at original flag paths |

## Proof capture checklist

Every time you get a shell:

```text
# Linux
hostname; id; ip a; cat /home/*/local.txt 2>/dev/null; cat /root/proof.txt 2>/dev/null

# Windows
hostname & whoami & ipconfig /all
type C:\Users\*\Desktop\local.txt
type C:\Users\Administrator\Desktop\proof.txt
```

**Screenshot requirements (discipline):**

- Flag content visible in the same screenshot as `hostname` / `whoami` / IP
- Clear path showing how you got there (for the report)
- Do not rely on memory after 23 hours — document live

## Exam-day ops tips (from practice + community consensus)

1. **Template your report early** — fill machines as you own them.
2. **Two notes streams:** (a) attack path / commands, (b) loot table (users, hashes, shares, interesting files).
3. **Time boxes:** e.g. 90–120 min on a dead end → park it, switch target, return later.
4. **Stable reverse shells** — upgrade TTY on Linux; prefer ports that egress (443, 80, 53) when firewalled.
5. **AD first or second**, not last — fatigue kills AD chains.
6. **Sleep is a tool** — short rest often unlocks stuck privesc.

## Recommended practice platforms (OSCP-shaped, 2026)

Labs did **not** go away. As of 2026:

| Source | Role |
|--------|------|
| PEN-200 module labs + **9 challenge labs** | Primary. **Three** challenge labs (community: OSCP A/B/C) replicate the exam set. |
| **Proving Grounds Practice** ($19/mo) | OffSec Windows/Linux + **retired OSCP+ exam labs**, unlimited time |
| PG Play (free) | Linux-only VulnHub-community machines, 3h limit |
| LainKusanagi list + TJ Null **v3** | HTB/PG volume filter (v3 = current OSCP+) |
| HTB Pro Labs Dante / Zephyr | Multi-host + AD networks |
| GOAD-Light / Ludus | Home Windows AD (Docker cannot do this) |
| This repo [Docker range](../labs/docker/README.md) | Offline Linux: upload, LFI, SQLi, sudo, pivot |

Full names, 2026 HTB additions, HackTrack, and a study sequence: **[practice-labs-2026.md](../resources/practice-labs-2026.md)**.

Community default: time-box **OSCP A/B/C** like exam day; treat Zeus/Poseidon as harder-than-exam optional.

## Pricing snapshot (check OffSec for current)

Approximate public figures in 2026 guides (USD; verify on offsec.com):

- PEN-200 course bundles / Learn One / Learn Unlimited vary
- Exam attempts and retakes are product-specific

Always confirm live pricing and exam attempts on [OffSec PEN-200](https://www.offsec.com/courses/pen-200/).

## Mental model of the exam network

```
                    [ Your Kali / Attack box ]
                              |
                     VPN / exam entry network
                              |
          +-------------------+-------------------+
          |                   |                   |
     Standalone A        Standalone B        Standalone C
     (20 pts)            (20 pts)            (20 pts)
                              |
                     AD set (assumed breach)
                              |
                    [ MS / App host ]  --pivot-->  [ Internal ]
                              |                        |
                         lateral move              [ DC ]
```

**Right mental model for AD:** foothold → local admin/SYSTEM → credential material → lateral → domain admin → DC proof.
