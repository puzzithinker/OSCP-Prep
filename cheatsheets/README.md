# Cheatsheets — how this repo uses them

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

## Files in this folder

| File | Use when |
|------|----------|
| [commands.md](commands.md) | General OSCP command reference (recon → AD → crack) |
| [proof-and-loot.md](proof-and-loot.md) | Flag capture + quick loot |
| [ad-quick.md](ad-quick.md) | AD spray / roast / dump / lateral |
| [privesc-quick.md](privesc-quick.md) | Windows + Linux privesc triage |
| [transfer-and-shells.md](transfer-and-shells.md) | File transfer matrix + reverse shells + breakouts |

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
