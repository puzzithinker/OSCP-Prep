# Penetration Test Report Outline (OSCP-style)

Use this structure for practice reports and exam submissions. Confirm current requirements in the official exam guide.

**Preferred tooling (2026):** [SysReptor + OffSec designs](reporting-sysreptor.md) via [Syslifters/OffSec-Reporting](https://github.com/Syslifters/OffSec-Reporting) — markdown findings → PDF. This outline still applies whether you use SysReptor, pandoc, or Word.

## 1. Cover / metadata

- Student email / OSID (as required)
- Exam / engagement date
- Document title

## 2. Introduction

- Purpose of the assessment  
- High-level objective (internal network penetration test)  
- Scope summary  

## 3. High-level summary (non-technical)

- Business language overview of risk  
- Systems compromised (host list, no exploit porn)  
- Overall risk statement  

### 3.1 Recommendations (executive)

- Patching / hardening themes  
- Credential hygiene  
- Segmentation / exposure  

## 4. Methodology

Brief description of approach:

1. Information gathering  
2. Vulnerability identification  
3. Exploitation  
4. Post-exploitation / lateral movement  
5. Reporting  

## 5. Per-host findings (technical)

Repeat for each host:

### 5.x System IP: `x.x.x.x` (hostname if known)

#### Service enumeration

| IP | Ports open |
|----|------------|
| x.x.x.x | TCP: … / UDP: … |

#### Initial foothold

- Vulnerability explanation  
- Step-by-step exploitation with commands  
- Screenshots  
- Severity  
- Remediation  

#### Privilege escalation (if applicable)

- Same structure as foothold  
- Final proof screenshot + flag value  

## 6. Active Directory set (if applicable)

- Topology narrative (who pivots where)  
- Chain of credentials without leaving out reproducibility  
- DA / DC compromise evidence  

## 7. Maintaining access / house cleaning

Short statements:

- What was installed  
- What was removed after testing  

## 8. Appendix

| Host | local.txt | proof.txt |
|------|-----------|-----------|
| | | |

Optional: tool list, script snippets, hash of submitted PDF.

---

## Writing quality bar

| Do | Don't |
|----|-------|
| Number figures and refer to them | Dump raw tool output without narrative |
| Show identity in proof shots | Crop away hostname/whoami |
| Explain impact + fix | Claim “hacked” with no steps |
| Keep commands copy-pasteable | Rely on “then I used a tool” |

## Practice drill

After each lab machine, write a **one-host mini-report** using section 5 only. Exam report stamina is a trained skill.
