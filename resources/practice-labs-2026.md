# Practice labs in 2026

**Short answer:** Yes. There is no shortage of OSCP-shaped machines in 2026. You do not need to wait for a new platform to appear.

What changed versus older writeups is *where* the closest practice lives: **PEN-200 challenge labs** and **Proving Grounds Practice** (including retired OSCP+ exam labs) are the primary exam replicas. HTB / TJ Null / LainKusanagi are still the volume layer. Home AD (GOAD) and the local Docker range in this repo cover gaps when you are offline or drilling one skill.

> Authorized training only. Do not attack systems you do not own or have permission to test. Do not copy or publish restricted OffSec exam/course material.

Related: [exam-overview-2026.md](../00-exam/exam-overview-2026.md) · [required-knowledge-2026.md](../00-exam/required-knowledge-2026.md) · [topic-tracker.md](../09-lab-writeups/topic-tracker.md) · [local Docker labs](../labs/docker/README.md)

---

## Priority order (what to spend time on)

| Rank | Source | Why it still matters in 2026 |
|------|--------|------------------------------|
| 1 | **PEN-200 module labs + 9 challenge labs** | Official private environments. Three challenge labs are built to **replicate the OSCP+ exam** (community: OSCP A / B / C). |
| 2 | **Proving Grounds Practice** | OffSec-authored Windows + Linux, **retired OSCP+ exam labs**, unlimited time. Closest public cousin of exam boxes. |
| 3 | **LainKusanagi OSCP-like list** | Community “grounded” list: exam-style boxes, extras harder than the exam stripped out. PG + HTB + THM + VulnLab. |
| 4 | **TJ Null / NetSecFocus Trophy Room v3** | Still the live spreadsheet TJ Null updates for PEN-200 / OSCP+. 0xdf mirrors HTB writeups as boxes are added (including 2026 retires). |
| 5 | **HTB machines + Pro Labs (Dante, Zephyr)** | Volume, AD chains, pivot networks. Some “OSCP like” boxes are *harder* than the exam. |
| 6 | **GOAD / GOAD-Light / Ludus** | Real Windows AD at home. Broader than OSCP depth — use it for assumed-breach muscle memory, not for collecting every ESC chain. |
| 7 | **PG Play (free) + VulnHub** | Linux fundamentals. Play = VulnHub-community machines on OffSec infra, Linux only, 3-hour limit. |
| 8 | **This repo’s Docker range** | Offline drills: web footholds, Linux privesc, loot reuse, dual-homed pivot. **Not** a Windows/AD substitute. |

Community consensus in 2025–2026 pass writeups: **do OSCP A/B/C under a 24h clock**, grind **PG Practice** (LainKusanagi/TJ Null subset), and treat Zeus/Poseidon as optional stretch.

---

## 1. Official OffSec (closest to the exam)

### PEN-200 (with course / Learn One / 90-day bundle)

Official 2026 course page:

- 20+ modules, most with **hands-on module labs**
- **9 challenge labs** that combine skills into pentest-style sets
- **Three challenge labs designed to closely replicate the OSCP+ exam** (3 standalones + AD-style set, assumed breach)

Community names you will see for those exam replicas: **OSCP A, OSCP B, OSCP C**. Harder named challenge labs often cited: **Zeus, Poseidon, Laser** (plus others such as Feast / Skylark depending on the current catalog). Treat names as catalog labels, not a dump of restricted content.

How to use them (SpecterOps + recent pass posts):

1. Finish module labs **as you study**, not in a binge at the end.
2. Save **OSCP A/B/C** for the last 1–2 weeks. Time-box like exam day (23h45m hacking + report).
3. SpecterOps (Mar 2025): attempt **two** exam-replica networks in a 48h window (24h test + report each) *before* the first exam; keep the third for a postmortem if you fail.
4. Write a real report per set ([report-outline.md](report-outline.md), [SysReptor](reporting-sysreptor.md)).
5. OffSec onboarding still correlates **>50 lab machines completed** with higher pass rate. PG Play/Practice is extra reps, **not** a substitute for PEN-200 labs.

Learn One (OffSec, Aug 2026): one 200/300-level course, 365 days of labs, two exam attempts, and **200+ PG Practice labs**.

### HackTrack (new in Aug 2026)

OffSec launched **HackTrack**: a free 10-week, Saturday, mentor-led walkthrough series for **PEN-200 learners with active lab access**. Mentors work OSCP-style machines (example focus for week 1: PG-style **Robust** — web enum, SQLi, post-ex credential discovery). Use it for methodology, not as a spoiler feed.

- Announced by [@offsectraining](https://x.com/offsectraining) (10–14 Aug 2026)

### Proving Grounds

| Tier | Cost (public 2026) | What you get |
|------|--------------------|--------------|
| **Play** | Free | 50+ dedicated Linux labs, mostly VulnHub-community; **3-hour** instance limit |
| **Practice** | **$19/mo or $199/yr** | 200+ labs, **Windows + Linux**, OffSec-designed machines, **retired OSCP+ exam labs**, **unlimited** time, new labs monthly, UGC machines |

Practice is the right buy if you do not currently have PEN-200 lab access, or you want extra Windows/AD-ish boxes after challenge labs. Play is useful *before* you pay, for Linux enum/privesc reps.

Portal: [offsec.com/products/proving-grounds](https://www.offsec.com/products/proving-grounds/) · getting started: [PG Play and Practice](https://help.offsec.com/hc/en-us/articles/360048318472-Getting-Started-with-PG-Play-and-Practice)

### Pricing snapshot (verify on offsec.com)

| Product | Public figure (2026) |
|---------|----------------------|
| Course + cert bundle (90 days, 1 attempt) | from **$1,749** |
| Learn One (1 year, 2 attempts, PG Practice) | **$2,749/year** |
| OSCP+ standalone exam | **$1,699** |
| PG Practice | **$19/mo** or **$199/yr** |

---

## 2. Community machine lists (still maintained)

Use **lists as filters**, not as a second syllabus. Prefer boxes that teach PEN-200 techniques at exam pace.

### LainKusanagi OSCP-like (start here for volume)

- Spreadsheet: [LainKusanagi OSCP-like](https://docs.google.com/spreadsheets/d/18weuz_Eeynr6sXFQ87Cd5F0slOj9Z6rt)
- Rated companion: [list with ratings](https://docs.google.com/spreadsheets/d/13YoNQuY6HC5ot-lZiX2tY9pR5mvwnp3xV6lHs78DlqQ)
- Tabs typically: **HackTheBox, PG Practice, TryHackMe, VulnLab**, with Windows standalones split from **AD Windows**
- Design goal (author): overlap with TJ Null, but **drop boxes harder than needed**

2026 pass posts still call this the “clutch” grind list, especially the **PG Practice** tab.

### TJ Null / NetSecFocus Trophy Room (v3)

- Spreadsheet: [NetSecFocus Trophy Room](https://docs.google.com/spreadsheets/d/1dwSMIAPIam0PuRBkCiDI88pU3yzrqqHkDtBngUHNCw8)
- TJ Null ([@TJ_Null](https://x.com/TJ_Null)): **v3 is the current list** for PEN-200 / OSCP+ (Oct 2024); he stated he will keep aligning it with the current course (Nov 2025: 0xdf auto-updates writeups when TJ adds HTB boxes)
- 0xdf tracker (HTB writeups mapped to the list): [0xdf.gitlab.io/cheatsheets/offsec](https://0xdf.gitlab.io/cheatsheets/offsec)

Use v3 **OSCP Like**, not v1/v2 (those still have BOF-era boxes).

### 2025–2026 HTB snapshot (OSCP Like, from 0xdf / TJ Null v3)

These are **examples of boxes added or still listed** as OSCP-like into 2026 — not a command to do all of them. Confirm on the live sheet (rotation is constant):

| When | OSCP Like (sample) | OSCP Harder (sample) |
|------|--------------------|----------------------|
| 2026 | Eighteen, Browsed, Expressway, Signed | DarkZero |
| late 2025 | Editor, Outbound, Voleur, TombWatcher, Puppy, Fluffy, TheFrizz | RustyKey, TombWatcher |
| 2025 | Dog, Titanic, Administrator, LinkVortex, Certified, Cicada | EscapeTwo, Vintage |

Classic AD-flavored HTB still on the like-list: **Active, Forest, Sauna, Monteverde, Blackfield, Cascade, Intelligence, Timelapse, Return, Support, Escape, Flight, Manager, Cicada, Certified, Administrator**.

### PG Practice names the community actually uses

OffSec-authored / PG boxes that show up repeatedly on LainKusanagi + prep checklists (Linux unless noted):

- **Warm-up / easy-ish:** Levram, Gaara, ClamAV, Crane, Hub; Windows: Kevin, Internal, Algernon
- **Intermediate grind:** Snookums, Pelican, Payday, Twiggy, Cockpit, Exfiltrated, Loly, Potato, FunboxEasyEnum, …
- **Harder Linux:** Zab, Vmdak, BitForge, Amaterasu, Stapler, Muddy, Hetemit, …
- **Windows standalones:** Slort, Jacko, Craft, AuthBy, DVR4, Mice, Fish, …
- **AD-tagged PG:** Hutch, Vault, Access, Resourced, Nagoya, Hokkaido, Nara, Heist
- **Mini-chains (2–3 host AD-ish):** POO, Heron, Tengu, Trusted, Reflection, Intercept
- **HackTrack example (Aug 2026):** Robust (web enum / SQLi / loot)

Do not treat community difficulty tags as exam difficulty. PG “intermediate” is often exam-plus.

### Combined checklists

- [Ch4os1/OSCP-Exam-Lab-Prep-List](https://github.com/Ch4os1/OSCP-Exam-Lab-Prep-List) — PG-heavy merge of LainKusanagi + Trophy Room (no writeups, OffSec-safe)

---

## 3. Other platforms worth time

| Platform | 2026 role |
|----------|-----------|
| **Hack The Box** VIP | Volume + current Windows/AD boxes on the v3 like-list. Retired machines need VIP. |
| **HTB Pro Labs** | **Dante** (first multi-host / pivot), **Zephyr** (AD-heavy). Closer to a network than a single box. Offshore / others are post-OSCP. |
| **HTB Academy** | CPTS path is denser than OSCP in places; useful for AD/web modules, not a PEN-200 replacement. |
| **TryHackMe** | Foundations + LainKusanagi THM tab. **Wreath** / AD rooms for assumed-breach practice. Offensive Pentesting path is pre-PEN-200, not exam replicas. |
| **VulnLab** | On LainKusanagi; Windows/AD-ish labs, often closer to “internal pentest” than HTB CTF. |
| **VulnHub** | Linux enum/privesc VMs you can import locally. Many of the same images are **free on PG Play**. |
| **PortSwigger Web Security Academy** | Free, excellent for *manual* SQLi / XSS / access control — complements standalones. |
| **HackerDNA / misc commercial lab farms** | Extra guided labs; not exam replicas. Optional. |

---

## 4. Home AD lab (Windows — Docker cannot replace this)

OSCP+ AD is **assumed breach**: you get a username/password and must enumerate, roast/spray, move laterally, and land DA/DC-class control. A local Windows lab is the only free way to drill that when OffSec/HTB AD sets are not running.

| Lab | Size | Notes |
|-----|------|--------|
| **[GOAD](https://github.com/Orange-Cyberdefense/GOAD)** | 5 VMs, 2 forests, 3 domains | Full attack playground; **deeper than OSCP** (ADCS, etc.). Practice the *OSCP-depth* path, skip rabbit holes. |
| **GOAD-Light** | 3 VMs, 1 forest, 2 domains | Best first home lab if RAM is limited. |
| **MINILAB** | 2 VMs (DC + Win10) | Kerberoast / AS-REP / PTH basics. |
| **[Ludus](https://docs.ludus.cloud/)** | Orchestrates GOAD on Proxmox | Less time fighting Vagrant. SpecterOps (2025) recommends this pattern. |

Hardware reality: this is RAM/disk heavy (often 32 GB+ for GOAD-Light). Mini-PC + Proxmox is the 2025–2026 homelab pattern.

---

## 5. Local Docker labs in this repo

Full Windows AD **does not** belong in Docker. What Docker *is* good for: fast, resettable, **offline** reps of exam habits on Linux.

This repo ships a small exam-shaped range:

[labs/docker/README.md](../labs/docker/README.md)

| Host | Skill mapped to BoK |
|------|---------------------|
| **harbor** (standalone) | Web enum, file-upload foothold, cron privesc, proof capture |
| **ledger** (standalone) | LFI → loot (SSH key), sudo GTFOBins (`find`) |
| **catalog** (standalone) | Manual SQLi → creds → SSH → SUID PATH hijack |
| **MS01 → APP01 → DC01** (chain) | Assumed-breach creds, loot reuse, dual-homed pivot, “DA” analog |

Use it to warm up methodology and Linux privesc **the same week** you are on PG/HTB, and whenever VPN labs are down. Then go back to OffSec/Windows boxes.

---

## 6. How many machines? (2026 community bar)

| If you… | Aim |
|---------|-----|
| Have PEN-200 access | All module labs you can + **OSCP A/B/C** timed + as many other challenge labs as time allows |
| Are supplementing with PG/HTB | **30–40** LainKusanagi / TJ Null v3 boxes is the number still quoted in 2026 roadmaps |
| Are weak on AD | PG AD boxes + one HTB Pro Lab (Dante then Zephyr) and/or GOAD-Light, **before** exam-replica challenge labs |
| Only have evenings | PG Practice on the LainKusanagi PG tab beats random HTB hard boxes |

Quality > count: a writeup in [09-lab-writeups/](../09-lab-writeups/) and a topic-tracker tick beats “rooted 80 boxes with a walkthrough open”.

---

## 7. Suggested sequence

```text
Foundations weak?
  → Linux/Windows admin, nmap, manual web  (THM / PortSwigger / PG Play)

PEN-200 enrolled
  → module labs in course order
  → PG Practice / LainKusanagi for extra reps of the *same* techniques
  → GOAD-Light or HTB AD boxes in parallel with AD modules
  → local Docker range for 45-min drills (upload, LFI, SQLi, sudo, pivot)
  → last 1–2 weeks: OSCP A, then B, then C (timed + report)
  → Zeus / Poseidon only if A/B/C felt comfortable

No PEN-200 yet
  → PG Play (free) + this Docker range
  → PG Practice subscription
  → HTB like-list / LainKusanagi
  → save real AD for GOAD-Light or HTB Pro Lab when you can spare RAM
```

---

## 8. What Docker / VulnHub will not teach you

| Gap | Where to practice it |
|-----|----------------------|
| Windows services, WinRM, SeImpersonate / Potato | PG Practice Windows, HTB Windows, PEN-200 |
| Real Kerberos, BloodHound, DCSync, PTH/PTT | PEN-200 AD + PG AD + GOAD / HTB AD |
| Exam stamina, reporting, proctoring constraints | OSCP A/B/C under the clock + SysReptor export |
| OffSec “house style” of boxes | PG Practice retired exam labs |

---

## 9. Source log (web + X, refreshed Aug 2026)

| Source | What we took |
|--------|----------------|
| [OffSec PEN-200](https://www.offsec.com/courses/pen-200/) | 9 challenge labs; 3 exam replicas; module labs; pricing |
| [OffSec Proving Grounds](https://www.offsec.com/products/proving-grounds/) | Play vs Practice; retired OSCP+ exam labs; $19/mo; Windows on Practice only |
| [PEN-200 2023 update](https://www.offsec.com/blog/pen-200-2023/) | Challenge-lab architecture (private sets, not shared legacy lab) |
| [PEN-200 onboarding](https://help.offsec.com/hc/en-us/articles/4406841351316) | PG is extra, not a substitute; >50 machines correlation |
| [SpecterOps — PEN-200 labs](https://specterops.io/blog/2025/03/25/getting-the-most-value-out-of-the-oscp-the-pen-200-labs/) | Report each lab; two timed exam-replica nets; GOAD + Ludus |
| [0xdf OffSec lists](https://0xdf.gitlab.io/cheatsheets/offsec) | Live HTB mapping of TJ Null v3, including **2026** boxes (Eighteen, DarkZero, …) |
| [@TJ_Null](https://x.com/TJ_Null) | v3 = current OSCP+ list; still updated (confirmed 2024–2025) |
| [@offsectraining](https://x.com/offsectraining) | HackTrack (Aug 2026); Learn One includes 200+ PG Practice labs |
| 2026 pass posts (e.g. “OSCP is a mental game”, Jun 2026) | LainKusanagi + OSCP A/B/C timed; Zeus/Poseidon optional-harder |
| [Ch4os1 prep list](https://github.com/Ch4os1/OSCP-Exam-Lab-Prep-List) | PG-centric named boxes + AD mini-chains + Dante/Zephyr |
| [GOAD](https://github.com/Orange-Cyberdefense/GOAD) | Home AD sizes (full / light / mini) |

Re-check OffSec pages near exam day — catalogs and prices move.
