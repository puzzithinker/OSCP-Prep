# Documentation & reporting — SysReptor / OffSec-Reporting

**Recommended stack for notes → exam-style PDF:**

- Project showcase: [Syslifters/OffSec-Reporting](https://github.com/Syslifters/OffSec-Reporting)  
- Platform: [SysReptor](https://github.com/Syslifters/sysreptor)  
- Docs: [docs.sysreptor.com](https://docs.sysreptor.com/)  
- Free OffSec cloud signup: [offsec.sysreptor.com/offsec/signup](https://offsec.sysreptor.com/offsec/signup/)

## Why this over pandoc-only / Word

| Need | SysReptor OffSec designs |
|------|---------------------------|
| Official-shaped OSCP+ report | Templates aligned with OffSec structure (with OffSec permission noted by Syslifters) |
| Markdown authoring | Write findings in MD, render PDF |
| Screenshots | First-class finding/report workflow |
| Other OffSec certs later | OSCP+, OSEP, OSWE, OSED, … same tool |
| Less LaTeX pain | No local Eisvogel fight under sleep debt |

Your older pandoc/Eisvogel report workflow still *works*; SysReptor is the better **default for 2026** if you want speed and fewer format bugs.

## Two ways to run it

### A) Hosted OffSec reporting (simplest)

1. Sign up at the OffSec SysReptor portal (free tier per project docs)  
2. Create an OSCP+ (or lab) project from the OffSec design  
3. Add hosts / findings as you hack  
4. Export PDF for submission  

Best when you do not want to maintain Docker during the exam window.

### B) Self-hosted SysReptor (full control)

From [OffSec-Reporting README](https://github.com/Syslifters/OffSec-Reporting):

1. Install SysReptor: [setup docs](https://docs.sysreptor.com/setup/installation/)  
2. Import OffSec designs:

```bash
cd sysreptor/deploy
url="https://docs.sysreptor.com/assets/offsec-designs.tar.gz"
curl -s "$url" | docker compose exec --no-TTY app python3 manage.py importdemodata --type=design
```

3. Use OSCP design for exam/lab reports  

## How it fits this knowledge base

```text
Lab/exam engagement
  ├─ Live notes: SysReptor findings (or markdown draft → paste later)
  ├─ Technique memory: this repo (00–08 + cheatsheets)
  ├─ Commands: arsenal-ng + cheatsheets/
  └─ Deliverable: SysReptor PDF (OSCP design)
```

Practice reports:

1. Compromise a PG/HTB box  
2. Write **one host** in SysReptor using the same fields you will use on exam day  
3. Export PDF once — learn the UI before the clock starts  

## Finding structure (map to our template)

| SysReptor / report section | This repo |
|----------------------------|-----------|
| Service enumeration | nmap table, ports |
| Vulnerability / foothold | Initial access steps + screenshots |
| Privilege escalation | Privesc steps + screenshots |
| Proof | identity + flag same evidence |
| Remediation | short fix language |

Also see: [report-outline.md](report-outline.md) and [WRITEUP-TEMPLATE.md](../09-lab-writeups/WRITEUP-TEMPLATE.md).

## Exam-day reporting discipline

- [ ] Project created **before** or immediately at start  
- [ ] Each foothold → finding drafted same hour  
- [ ] Screenshots uploaded as you go  
- [ ] Appendix / proof table complete before PDF export  
- [ ] Export PDF early in the 24h window; keep buffer for fixes  

## Privacy / policy

- Do not publish completed exam reports or restricted content  
- Hosted SaaS: review Syslifters/OffSec terms for what you upload  
- Self-host if you want data only on your machine  

## Sample public previews

Syslifters publish sample PDF previews (structure reference, not your content), e.g. from their docs assets — see the [OffSec-Reporting](https://github.com/Syslifters/OffSec-Reporting) README for OSCP and other cert previews.
