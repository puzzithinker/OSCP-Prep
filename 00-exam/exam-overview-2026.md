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
- [Changes to the OSCP](https://help.offsec.com/hc/en-us/articles/29840452210580-Changes-to-the-OSCP)

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

Examples of valid combinations (from public exam-guide style breakdowns):

| Path | Math |
|------|------|
| Full AD + 3 locals | 40 + 30 = **70** |
| Full AD + 2 locals + 1 proof | 40 + 20 + 10 = **70** |
| Partial AD + full standalones | e.g. 10 AD + 60 standalones = **70** |
| Full AD + mix of proofs | Flexible if you can count to 70 |

**Practical strategy for most candidates:**

1. **Secure the AD set first** (40). It is the largest single block and is designed as a chain.
2. Then farm **standalone local.txt** flags for partial credit.
3. Escalate standalones only when the path is clear — do not burn hours on one rabbit hole.

## What is *not* on the exam

| Topic | Status |
|-------|--------|
| Buffer overflow | Removed from exam long ago — skip dedicated BOF grinding for OSCP |
| Advanced ADCS / forest trusts / complex delegation chains | Beyond typical OSCP depth (great for OSEP/CRTO, not required here) |
| AWS module | Present in updated course material; **not yet exam content** per OffSec change notes |

## What *is* heavily weighted

- Deep **enumeration** (web, SMB, LDAP, WinRM, MSSQL, history files, shares)
- **Credential hunting** and reuse
- **Windows + Linux privilege escalation** fundamentals
- **Active Directory authentication attacks** at OSCP depth: password spray, AS-REP roast, Kerberoast, PTH/PTT, secrets dump, DCSync-class domain dominance
- **Pivoting / tunneling** into double-homed hosts and internal subnets
- **Professional report** with reproducible steps and proof screenshots

## Metasploit policy (mind the limit)

OffSec historically limits unrestricted Metasploit use. Default mindset:

- Prefer **manual** exploitation and shells (`msfvenom` payloads are fine; interactive MSF exploit modules are constrained).
- Know the current exam rules from the official guide on exam day — policies are what OffSec publishes, not what Reddit remembers.

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

## Recommended practice platforms (OSCP-shaped)

- OffSec PEN-200 labs + challenge labs (primary)
- HackTheBox / Proving Grounds Practice (Windows + AD paths)
- VulnHub for Linux fundamentals
- Home AD lab (2–3 Windows + DC) for muscle memory

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
