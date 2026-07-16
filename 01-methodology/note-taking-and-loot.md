# Note-Taking & Loot Management

Good notes win exams. Bad notes turn 70-point runs into report failures.

## Folder layout

```text
~/exam/
  scans/           # nmap, autorecon
  hosts/
    10.10.10.10/   # per-target scratch
  loot/
    loot.md        # master table
    hashes/        # tagged by type
    tickets/
    files/         # downloaded configs, kdbx, etc.
  screenshots/
  notes/
    journal.md     # timeline
  report/          # draft sections
  tools/           # HTTP root for transfers
  payloads/
```

## Master loot table

Keep **one** living file (`loot/loot.md`):

```markdown
| Time | Secret | Type | User | Source host | Source detail | Tried on | Result |
|------|--------|------|------|-------------|---------------|----------|--------|
| 10:12 | Summer2026! | pass | jsmith | 10.10.10.5 | web.config | smb/24 | admin on .7 |
| 11:40 | aad3...:1aee... | ntlm | Administrator | 10.10.10.7 | secretsdump | psexec .7 | SYSTEM |
```

Rules:

1. Log a secret **before** you spray it  
2. Record **negative** results so you do not re-try blindly  
3. Tag hash types (`ntlm`, `netntlmv2`, `tgs`, `asrep`)  

## Host scratchpad (minimal)

```markdown
# 10.10.10.10
## Ports
80,445,3389

## Attack tree
80 → /admin → default creds → upload → shell (iis apppool)
  → SeImpersonate → SYSTEM

## Creds found
- ...

## Next
- spray SYSTEM hashes
```

## Timeline journal

When fatigue hits, a timeline saves the report:

```markdown
## 09:00 VPN up, tun0=...
## 09:15 full scans launched
## 10:40 foothold .10 as www-data
## 11:05 root .10 — parked AD
```

## Screenshot discipline

| When | Capture |
|------|---------|
| Foothold | whoami/id + host + local flag |
| Privesc | elevated context + proof flag |
| Lateral | auth success + new host identity |
| Critical error | sometimes — proves dead end |

Filenames:

```text
10.10.10.10_local.png
10.10.10.10_proof.png
10.10.10.20_winrm_jsmith.png
```

## Report-as-you-go

After each full compromise, draft:

1. Service table  
2. Foothold narrative + commands  
3. Privesc narrative + commands  
4. Paste flag values into appendix  

Do not leave all writing for the final 24 hours.

## Loot-first post-exploit checklist

Every new shell:

```text
[ ] Identity (whoami/id, hostname, IP)
[ ] Flags if present
[ ] Privileges (whoami /priv, sudo -l)
[ ] History files
[ ] Network / routes / dual-homed?
[ ] Interesting files & shares
[ ] Dump creds if admin
[ ] Update loot.md
[ ] Spray new secrets
```

## Tools for notes

Pick one and stick to it under pressure:

| Tool | Pros |
|------|------|
| Markdown in git (this repo) | Versioned, portable |
| Obsidian / CherryTree | Fast linking, local |
| Simple `notes/*.md` + screenshots | Lowest friction |

Avoid rewriting tooling mid-exam.

## Hygiene

- Do not commit real exam secrets to public git remotes  
- Scrub customer/lab passwords before sharing writeups  
- Prefer private repos for personal practice notes  
