# Community sources — how we used them

This knowledge base is curated, not a mirror. Two large public collections informed expansions:

| Source | URL | How we used it |
|--------|-----|----------------|
| **0xsyr0/OSCP** | https://github.com/0xsyr0/OSCP | Modern OSCP+ command/tool sheet: web (LFI/upload/SQLi), file transfer, pivot (chisel/ligolo/SSH), SNMP/NFS/SMB recipes, exam notes (e.g. sqlmap restrictions), tool index. We **paraphrased and folded** high-value patterns into `02`–`08` and `cheatsheets/` — we did **not** paste the mega-README or CVE catalogs. |
| **Cheatsheet-God** | https://github.com/OlivierLaflamme/Cheatsheet-God | Topic `.txt` bank: shells, file transfer, SQLi, SMB, pivoting, Linux enum ideas. Older (some Backtrack-era links). We took **OSCP-relevant command ideas only**, modernized tooling (NetExec, placeholders), and skipped BOF/wireless/VOIP/AIX bulk content. |

## What we deliberately did *not* import

- Full `Cheatsheet_*.txt` trees or 0xsyr0 README as a single file  
- Nested clones / submodules of either repo  
- Entire CVE / ADCS / exploit-dev catalogs (link out if needed)  
- Restricted OffSec exam or course material  

## License / attribution

Third-party text is **not** claimed as original. Prefer linking upstream for deep lists; keep this repo’s voice, structure, and 2026 exam scope. See each project’s license on GitHub before redistributing large excerpts.

## Where enrichment landed

| Gap area | Primary files |
|----------|----------------|
| Web LFI / upload / SQLi | `03-initial-access/web-attacks.md` |
| Transfer + shells | `cheatsheets/transfer-and-shells.md`, `03-initial-access/shells-payloads.md` |
| SNMP / NFS / SMB multi-get | `02-recon/enumeration.md` |
| Pivot variants | `06-pivoting/tunneling.md` |
| Spray / hydra / kerbrute | `07-password-attacks/cracking.md` |
| MSSQL discovery | `08-mssql/attacks.md` |
| Credits / links | this file, `resources/links.md` |
