# Scoring Strategy (70/100)

## Point map (current public structure)

| Target | Points | Split |
|--------|--------|-------|
| Standalone × 3 | 60 | 10 foothold + 10 privesc each |
| AD set (3 hosts) | 40 | 10 + 10 + 20 (typical guide wording) |
| Bonus | 0 | Removed Nov 2024 |
| **Pass** | **70** | |

Always confirm live numbers in the [official exam guide](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide).

## Pass combinations (examples)

Aligned with public exam-guide / FAQ style paths:

| Strategy | Math | Risk |
|----------|------|------|
| Full AD + 3 locals | 40+30=**70** | Best balance for most candidates |
| Full AD + 2 locals + 1 proof | 40+20+10=**70** | Need one standalone privesc |
| Full AD + 1 full standalone + 1 local | 40+20+10=**70** | Same math as above, different hosts |
| **20** AD + 3 locals + 2 proofs | 20+30+20=**70** | Viable if AD chain stalls mid-set |
| **10** AD + 3 full standalones | 10+60=**70** | Possible but stressful — zero margin |
| No AD + all standalones | 0+60=**60** | **Fail** without AD points |

**Implication:** Treating AD as optional is a losing strategy for most candidates. Skill depth required: [required-knowledge-2026.md](required-knowledge-2026.md).

## Priority order

```text
1. Establish AD foothold (provided creds) and map set
2. Secure dual-homed pivot + tunnel
3. Complete AD chain to DA / DC (40)
4. Farm standalone local.txt flags (fast points)
5. Escalate standalones when path is clear
6. Revisit parked hosts only with fresh ideas
```

## Time allocation model (example)

| Phase | Hours | Goal |
|-------|-------|------|
| Recon all | 0–1.5 | Full ports + service map |
| AD chain | 1.5–10 | 40 points locked |
| Standalone footholds | 10–16 | 3× local if possible |
| Hard privescs | 16–20 | Convert locals to proofs |
| Sweep + screenshots | 20–23.75 | No missing evidence |

Adjust if AD falls early (then push standalones) or if a standalone is free points first (take them, return to AD).

## Decision rules

| Situation | Decision |
|-----------|----------|
| AD stuck 2h, standalone open ports juicy | Rotate to standalone for a local, return to AD |
| One standalone eats 3h with no foothold | Park it |
| You have 40 AD + 2 locals | You need 10 more — hunt one local or one proof |
| You have 60 standalone, 0 AD | AD is mandatory focus now |
| Sleep deprivation, 50 points | Short rest > random exploits |

## Partial credit mindset

A low-priv shell is **not** a failure:

- 10 points toward pass  
- Loot may feed AD or other hosts  
- Document it fully for the report  

## Report scoring risk

Technical compromise without evidence can lose points:

- Missing flag screenshots  
- Unreproducible steps  
- Wrong host attribution  

Treat the report as part of the score, not an afterthought.

## Mental math card

```text
AD full ........ 40
local × N ...... 10N
proof × M ...... 10M
----------------
need 70
```

Keep a running total in `notes/journal.md`.
