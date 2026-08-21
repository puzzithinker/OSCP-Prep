# Required Knowledge Map (OSCP / OSCP+ 2026)

What you must **know and do** for the practical exam. Sourced from OffSec’s public OSCP+ Exam Guide, PEN-200 materials, onboarding/FAQ, and change notes (post–1 Nov 2024 framework still current into 2026).

> Verify live rules in the [OSCP Exam Guide](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide) before exam day. This file is a study map, not OffSec policy.

Related: [exam-overview-2026.md](exam-overview-2026.md) · [scoring-strategy.md](scoring-strategy.md) · [topic-tracker.md](../09-lab-writeups/topic-tracker.md)

---

## 1. Background foundations (before / alongside PEN-200)

No formal prerequisites. OffSec frames readiness as hands-on admin + networking + scripting:

| Domain | Expected capability |
|--------|---------------------|
| **TCP/IP** | Addressing, subnetting, common protocols/services, how traffic is delivered and received |
| **Linux admin** | Users/groups, filesystems, services, packages, basic process/network troubleshooting |
| **Windows admin** | Users/groups, services, shares, PowerShell basics, basic AD awareness (domains, users, GPO concept) |
| **Scripting** | Bash and/or Python fluency for automation, parsing enum output, small glue scripts (Perl sometimes listed as a plus) |

If these are weak, fix them before grinding exploit techniques — exam speed depends on admin comfort, not just payloads.

---

## 2. Core skill domains (exam body of knowledge)

These domains define required practical knowledge:

| Domain | Must be able to… | Repo home |
|--------|------------------|-----------|
| **Enumeration & info gathering** | Methodical host/service/web/AD enum; turn noise into attack surface | [02-recon/](../02-recon/) |
| **Web / service initial access** | XSS concepts, command injection, directory traversal, file uploads, SQLi, public exploit adapt | [03-initial-access/](../03-initial-access/) |
| **Password attacks** | Identify hashes, crack (Hashcat/John), spray, reuse loot | [07-password-attacks/](../07-password-attacks/) |
| **Windows privilege escalation** | Priv triage, service/misconfig paths, token abuse, cred hunting | [04-privilege-escalation/windows.md](../04-privilege-escalation/windows.md) |
| **Linux privilege escalation** | sudo/SUID/cron/creds/kernel when matched | [04-privilege-escalation/linux.md](../04-privilege-escalation/linux.md) |
| **Pivoting & tunneling** | Port redirect, SSH tunnels, SOCKS/TUN through dual-homed hosts; DPI-style tunneling concepts from course | [06-pivoting/](../06-pivoting/) |
| **Active Directory (assumed breach)** | Enum as domain user → auth attacks → lateral → domain compromise | [05-active-directory/](../05-active-directory/) |
| **Metasploit (limited)** | Use within exam constraints; prefer manual shells | See §5 below |
| **Professional reporting** | Reproducible steps, proof screenshots, correct packaging/upload | [resources/report-outline.md](../resources/report-outline.md) |

### AD depth (high weight)

Prep should cover course-level material and challenge-style AD sets:

- Assumed-breach foothold with provided username/password  
- Domain enum (users, groups, computers, shares, SYSVOL)  
- Password spraying  
- AS-REP roasting + Kerberoasting (obtain → crack → reuse)  
- Pass-the-hash / pass-the-ticket  
- Secrets dump / DCSync-class domain dominance  
- Pivoting inside the AD set when hosts are dual-homed  

**Stretch (not typical OSCP depth):** advanced ADCS ESC chains, complex delegation forests — awareness only unless course exercises demand it.

---

## 3. PEN-200 module map → exam domains

High-level course modules that feed the exam (names follow public PEN-200 / 2023+ structure):

| Module theme | Exam relevance |
|--------------|----------------|
| Information Gathering | Always — foundation of every host |
| Vulnerability Scanning | Supporting enum; mass scanners restricted on exam |
| Web application attacks (intro, common, SQLi) | Standalone footholds heavily |
| Password Attacks | Cross-cutting loot reuse |
| Windows Privilege Escalation | Standalones + AD clients |
| Linux Privilege Escalation | Standalones |
| Port Redirection and SSH Tunneling | AD / dual-homed paths |
| Tunneling through Deep Packet Inspection | Advanced tunnel variants from course |
| The Metasploit Framework | Allowed with **strict limits** (§5) |
| Active Directory Introduction and Enumeration | AD set |
| Attacking Active Directory Authentication | AD set |
| Lateral Movement in Active Directory | AD set → DA/DC |

### OffSec 12-week learning sequence (study order)

Suggested course order (adapt to your pace):

1. Web enumeration / exploitation + public exploit use  
2. Password attacks  
3. Windows & Linux privilege escalation  
4. Port redirection / SSH + advanced tunneling  
5. Metasploit (within policy)  
6. AD enumeration → authentication attacks → lateral movement  

Track hands-on mastery in [topic-tracker.md](../09-lab-writeups/topic-tracker.md).

---

## 4. What the exam tests (format)

| Item | Detail |
|------|--------|
| Hands-on | **23 hours 45 minutes** proctored practical |
| Report | **24 hours** after exam ends to upload documentation |
| Pass mark | **70 / 100** |
| Standalones | 3 machines × **20** (10 initial access + 10 privesc) = **60** |
| AD set | 3 machines = **40** (**10 + 10 + 20**), partial credit possible |
| Bonus | Lab/course points **do not count** (removed Nov 2024) |
| AD model | Assumed breach — username + password provided |

### Official-style paths to 70 (examples)

| Path | Math |
|------|------|
| Full AD + three `local.txt` | 40 + 30 = **70** |
| Full AD + two `local.txt` + one `proof.txt` | 40 + 20 + 10 = **70** |
| **20** AD points + three `local.txt` + two `proof.txt` | 20 + 30 + 20 = **70** |
| **10** AD points + three fully completed standalones | 10 + 60 = **70** |

See [scoring-strategy.md](scoring-strategy.md) for time models and decision rules.

### Credential outcome

| Credential | Validity |
|------------|----------|
| **OSCP** | Lifetime (brand) |
| **OSCP+** | 3 years — maintain via recert, qualifying OffSec cert, or CPE |

OSCP+ is a **currency** designation, not a second hands-on syllabus.

---

## 5. Tools: allowed patterns vs restrictions

Confirm live wording in the exam guide. Working mental model for 2026 prep:

### Generally restricted / prohibited (examples)

- Spoofing / poisoning techniques where banned  
- Commercial tools (e.g. Metasploit Pro, Burp Suite Professional)  
- Automatic exploitation tools (e.g. SQLmap)  
- Mass vulnerability scanners  
- AI chatbots / LLMs with **direct prompt access** during the exam  

### Metasploit limits (critical)

| Allowed more broadly | Constrained |
|----------------------|-------------|
| `msfvenom` payload generation | Auxiliary / Exploit / Post modules |
| `multi/handler` listeners | **Meterpreter** and exploit modules against **only one chosen target** (locked on first use) |
| | No multi-target pivoting *via Metasploit* across hosts |

Default training habit: **manual shells**; treat MSF as a single-host tool, not a network pivot platform.

### Common allowed toolkit (non-exhaustive)

Nmap/NSE, Nikto, Burp Free, BloodHound CE, Impacket, Mimikatz, evil-winrm, Rubeus, Responder (**without** poisoning/spoofing where prohibited), NetExec, chisel/ligolo-ng, hashcat/john, etc.

OffSec will not enumerate every allowed binary — if unsure, prefer manual techniques already in PEN-200.

Local tooling notes: [resources/links.md](../resources/links.md) · [cheatsheets/](../cheatsheets/)

---

## 6. Proofs and report packaging

### During the exam

- Submit proof-file contents in the **exam control panel** before time ends  
- Capture interactive-shell screenshots: `cat` / `type` from **original flag paths**, with host identity (hostname, whoami/id, IP) visible  

### Report deliverable

| Requirement | Detail |
|-------------|--------|
| Filename | `OSCP-OS-XXXXX-Exam-Report.pdf` (use your OSID) |
| Archive | Password-free **`.7z`**, under **200 MB** |
| Upload | [upload.offsec.com](https://upload.offsec.com) within **24 hours** of exam completion |
| Content | Professional step-by-step pentest report (reproducible steps + screenshots) |

Practice with [report-outline.md](../resources/report-outline.md) and [reporting-sysreptor.md](../resources/reporting-sysreptor.md).

---

## 7. Explicitly out of exam scope

| Topic | Status for exam BoK |
|-------|---------------------|
| **Buffer overflows** | Removed with 2023 PEN-200 revision; still **not** exam content in 2026 |
| **AWS module** | In course materials; public FAQ / change notes treat as **not exam content** (re-check guide before exam) |
| **Advanced ADCS / deep forest trusts / complex delegation** | Beyond typical OSCP depth |
| **Heavy commercial C2** | Overkill; manual shells preferred |

Deprioritize these when study time is scarce — see also [resources/links.md](../resources/links.md) “What to deprioritize”.

---

## 8. Capability checklist (one-page self-test)

You are exam-ready when you can, without heavy notes:

- [ ] Enumerate a host end-to-end and write a clear attack surface summary  
- [ ] Gain web or service foothold and stabilize a reverse shell  
- [ ] Transfer tools and loot on Windows and Linux under pressure  
- [ ] Escalate Windows and Linux to admin/root on “OSCP-like” boxes  
- [ ] Crack and reuse passwords/hashes from loot  
- [ ] From domain-user creds: enum AD, roast/spray, lateral, reach DA/DC-class control  
- [ ] Pivot through a dual-homed host (SOCKS or TUN) and attack an internal subnet  
- [ ] Obey Metasploit single-target discipline by habit  
- [ ] Produce a clean PDF report section per host with proofs  

Detail boxes: [topic-tracker.md](../09-lab-writeups/topic-tracker.md)

---

## 9. Official sources (refresh periodically)

| Source | URL |
|--------|-----|
| OSCP / OSCP+ Exam Guide | https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide |
| OSCP Exam FAQ | https://help.offsec.com/hc/en-us/articles/4412170923924-OSCP-Exam-FAQ |
| Changes to the OSCP | https://help.offsec.com/hc/en-us/articles/29840452210580-Changes-to-the-OSCP |
| OSCP Exam Changes | https://help.offsec.com/hc/en-us/articles/29865898402836-OSCP-Exam-Changes |
| PEN-200 course page | https://www.offsec.com/courses/pen-200/ |
| PEN-200 onboarding | https://help.offsec.com/hc/en-us/articles/4406841351316-PEN-200-Onboarding-A-Learner-Introduction-Guide-to-the-OSCP |
| PEN-200 FAQ | https://help.offsec.com/hc/en-us/articles/12483872278932-PEN-200-FAQ |
| 12-week learning plan | https://help.offsec.com/hc/en-us/articles/15541765522196-OffSec-PEN-200-Learning-Plan-12-Week |
| PEN-200 2023 blog (module framing) | https://www.offsec.com/blog/pen-200-2023/ |

### Known uncertainties (as of research refresh)

- Exact AD host roles/topology can vary per attempt; control panel is authoritative  
- Allowed-tool list is non-exhaustive; OffSec does not comment on every binary  
- AWS remains “course, not exam” in public FAQ language — re-verify near exam date  
- No public fine-grained checklist of every AD technique; train to **module + lab** depth  

---

## 10. How this map drives study in this repo

```text
Foundations weak?     → networking + Win/Linux admin + Bash/Python drills
Domain gaps?          → sections 02–08 + cheatsheets + topic-tracker
Exam format gaps?     → exam-overview + scoring-strategy + exam-day-checklist
Report muscle memory? → report-outline + SysReptor practice export
Hands-on proof?       → 09-lab-writeups after every box
Live machines 2026?   → resources/practice-labs-2026.md (PEN-200, PG, lists, GOAD)
Offline Linux reps?   → labs/docker (not a Windows/AD substitute)
Command under fire?   → cheatsheets/README.md (domain → file map) + arsenal-ng
```

**Cheatsheet index (CLI under pressure):** [cheatsheets/README.md](../cheatsheets/README.md)

**Reliable study priority:** enumeration → footholds → password attacks → privesc → tunneling → AD chain → reporting under MSF/tool constraints.
