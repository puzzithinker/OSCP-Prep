# OSCP Prep Knowledge Base

Personal study repository for Offensive Security Certified Professional (OSCP / OSCP+) preparation: methodology, techniques, cheatsheets, and lab tracking.

> For authorized training and personal study only. Respect OffSec terms, NDA, and exam rules. Do not share restricted exam or course content.

## Quick navigation

| Section | Path | Focus |
|--------|------|--------|
| Exam overview (2026) | [00-exam/](00-exam/) | Format, scoring, OSCP+, strategy |
| Exam-day checklist | [00-exam/exam-day-checklist.md](00-exam/exam-day-checklist.md) | Ops checklist under pressure |
| Scoring strategy | [00-exam/scoring-strategy.md](00-exam/scoring-strategy.md) | How to plan for 70 points |
| Methodology | [01-methodology/](01-methodology/) | Kill chain, note-taking, exam ops |
| Notes & loot | [01-methodology/note-taking-and-loot.md](01-methodology/note-taking-and-loot.md) | Workspace, loot table, screenshots |
| Recon | [02-recon/](02-recon/) | Scanning, service enum (SMB/NFS/SNMP) |
| Initial access | [03-initial-access/](03-initial-access/) | Web, services, shells, common patterns |
| Web attacks | [03-initial-access/web-attacks.md](03-initial-access/web-attacks.md) | LFI, upload bypass, manual SQLi |
| Transfer & shells | [cheatsheets/transfer-and-shells.md](cheatsheets/transfer-and-shells.md) | File move + reverse shells |
| Report outline | [resources/report-outline.md](resources/report-outline.md) | Practice / exam report structure |
| Community sources | [resources/community-sources.md](resources/community-sources.md) | 0xsyr0 + Cheatsheet-God usage notes |
| Privilege escalation | [04-privilege-escalation/](04-privilege-escalation/) | Windows & Linux |
| Active Directory | [05-active-directory/](05-active-directory/) | Enum, auth attacks, lateral, DA |
| AD decision flow | [05-active-directory/decision-flow.md](05-active-directory/decision-flow.md) | What to try next |
| Pivoting | [06-pivoting/](06-pivoting/) | Chisel, ligolo, SOCKS, proxychains |
| Password attacks | [07-password-attacks/](07-password-attacks/) | Hashcat/John modes |
| MSSQL | [08-mssql/](08-mssql/) | Linked servers, xp_cmdshell, relay |
| Lab writeups | [09-lab-writeups/](09-lab-writeups/) | Template + your own notes |
| Topic tracker | [09-lab-writeups/topic-tracker.md](09-lab-writeups/topic-tracker.md) | PEN-200 syllabus checklist |
| Cheatsheets | [cheatsheets/](cheatsheets/) | Curated markdown (old dump retired) |
| Terminal launcher | [resources/arsenal-ng.md](resources/arsenal-ng.md) | [arsenal-ng](https://github.com/halilkirazkaya/arsenal-ng) |
| Reporting | [resources/reporting-sysreptor.md](resources/reporting-sysreptor.md) | [OffSec-Reporting](https://github.com/Syslifters/OffSec-Reporting) / SysReptor |
| Resources | [resources/](resources/) | Links, tools, mindmaps |

## 2026 exam snapshot

- **Time:** 23h 45m hacking + 24h report
- **Score:** 70/100 to pass
- **Targets:** 3 standalone machines (20 pts each) + 1 AD set of 3 hosts (40 pts)
- **AD model:** Assumed breach — credentials provided for the AD set
- **Bonus points:** Removed (Nov 2024)
- **Cert split:** Passing PEN-200 yields **OSCP** (lifetime brand) + **OSCP+** (3-year renewable)
- **Buffer overflow:** Not on exam
- **AWS module:** In course materials, not exam (as of OffSec guidance)

**Reliable pass path:** Full AD (40) + three `local.txt` (30) = 70.

## How to use this repo

1. Read [00-exam/exam-overview-2026.md](00-exam/exam-overview-2026.md) and the [exam-day checklist](00-exam/exam-day-checklist.md).
2. Drill methodology and recon until automatic.
3. Study with [cheatsheets/](cheatsheets/); execute with [arsenal-ng](resources/arsenal-ng.md).
4. Draft findings in [SysReptor / OffSec-Reporting](resources/reporting-sysreptor.md) so PDF export is boring on exam day.
5. Track coverage with [topic-tracker.md](09-lab-writeups/topic-tracker.md).
6. After each practice machine, use [WRITEUP-TEMPLATE.md](09-lab-writeups/WRITEUP-TEMPLATE.md) and/or a SysReptor finding.
7. Before exam day: AD decision flow + pivoting + proof capture + one full practice PDF export.

## Tooling notes (2024–2026)

| Legacy | Prefer today |
|--------|----------------|
| CrackMapExec | **NetExec** (`nxc`) |
| Manual SOCKS only | **ligolo-ng** + chisel still valid |
| Metasploit-heavy | Limited MSF use on exam — prefer manual shells |

## Suggested study loop

```
Enumerate deeply → Document findings → Exploit → Loot → Privesc →
Screenshot proof → Lateral / pivot → Repeat → Report as you go
```

## Legal / ethics

Content is for authorized training, labs, and personal exam prep only. Do not use techniques against systems you do not own or have permission to test. Do not commit or publish restricted OffSec exam/course materials.
