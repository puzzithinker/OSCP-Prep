# Cheatsheets — how this repo uses them

Aligned to the exam BoK: [required-knowledge-2026.md](../00-exam/required-knowledge-2026.md)

## Recommendation

| Artifact | Keep? | Role |
|----------|-------|------|
| Old rushed `command.md` | **No (retired)** | One-time exam panic dump; messy IPs, typos, wrong hash modes |
| `cheatsheets/*.md` (this folder) | **Yes** | Curated, reviewed, study + offline reference |
| [arsenal-ng](https://github.com/halilkirazkaya/arsenal-ng) | **Yes (terminal)** | Searchable launcher; paste-ready commands during labs/exam |
| Concept pages (`00`–`08`) | **Yes** | *Why* and decision-making, not raw CLI |

**Do not maintain three copies of the same one-liners.** Flow:

```text
Learn concepts in 00–08
    → remember patterns in cheatsheets/*.md
    → execute via arsenal-ng (or copy from markdown under pressure)
```

## BoK domain → cheatsheet map

| Exam domain | Primary cheatsheet | Concept depth |
|-------------|-------------------|---------------|
| Enumeration & info gathering | [commands.md](commands.md) § Recon | [02-recon/](../02-recon/) |
| Web / service initial access | [commands.md](commands.md) § Web · [transfer-and-shells.md](transfer-and-shells.md) | [03-initial-access/](../03-initial-access/) |
| Shells & transfer | [transfer-and-shells.md](transfer-and-shells.md) | [03-initial-access/shells-payloads.md](../03-initial-access/shells-payloads.md) |
| Password attacks | [commands.md](commands.md) § Cracking · [ad-quick.md](ad-quick.md) spray | [07-password-attacks/](../07-password-attacks/) |
| Windows / Linux privesc | [privesc-quick.md](privesc-quick.md) | [04-privilege-escalation/](../04-privilege-escalation/) |
| Pivoting & tunneling | [commands.md](commands.md) § Pivoting | [06-pivoting/](../06-pivoting/) |
| Active Directory | [ad-quick.md](ad-quick.md) | [05-active-directory/](../05-active-directory/) |
| Metasploit (limited) | [commands.md](commands.md) § msfvenom | Exam guide + [required-knowledge §5](../00-exam/required-knowledge-2026.md) |
| Proofs & reporting | [proof-and-loot.md](proof-and-loot.md) | [resources/report-outline.md](../resources/report-outline.md) |
| MSSQL | [commands.md](commands.md) § MSSQL | [08-mssql/](../08-mssql/) |

Hands-on checklist: [topic-tracker.md](../09-lab-writeups/topic-tracker.md)

## Files in this folder

| File | Use when |
|------|----------|
| [commands.md](commands.md) | General OSCP command reference (recon → pivot → AD → crack) |
| [proof-and-loot.md](proof-and-loot.md) | Flag capture, loot tags, exam packaging reminders |
| [ad-quick.md](ad-quick.md) | Assumed-breach enum, spray, roast, dump, lateral |
| [privesc-quick.md](privesc-quick.md) | Windows + Linux privesc triage |
| [transfer-and-shells.md](transfer-and-shells.md) | File transfer matrix + reverse shells + breakouts |

## Exam constraints (keep in muscle memory)

| Rule | Habit |
|------|--------|
| Metasploit | `msfvenom` + `multi/handler` OK; exploit/post/Meterpreter → **one target only** |
| Prefer manual shells | Train without MSF multi-host pivots |
| No Pro / auto-exploit | Burp Free, no SQLmap, no mass scanners on exam |
| No LLM prompts on exam | Offline notes + this repo only |
| Proofs | Control panel **before** time ends; screenshot `cat`/`type` at original path + identity |

## Markdown vs arsenal-ng

| Need | Prefer |
|------|--------|
| Studying / reviewing / git history | Markdown here |
| Exam/lab speed, fuzzy search, `{{lhost}}` fill | **arsenal-ng** |
| Offline air-gapped notes | Markdown (export/print if needed) |
| Teaching yourself *why* | Concept docs, not cheatsheets |

See [resources/arsenal-ng.md](../resources/arsenal-ng.md) for install and how to add personal YAML cheats.

## Maintenance rules

1. After a hard box, add **one** missing command here (or to arsenal YAML) — not a second dump file  
2. Prefer **NetExec (`nxc`)** over CrackMapExec  
3. Placeholders: `LHOST`, `TARGET`, `DC`, `DOMAIN`, `USER`, `PASS`, `NTHASH`  
4. Never store real exam secrets in cheatsheets  
5. If a command belongs to a BoK domain, link the concept page once — do not duplicate full playbooks  
