# Proof Capture & Loot Cheatsheet

Exam packaging: [required-knowledge §6](../00-exam/required-knowledge-2026.md) · [report-outline.md](../resources/report-outline.md)

| When | Do |
|------|-----|
| Shell gained | Identity + flag same screenshot; submit value in **control panel** before exam ends |
| Flag path | `cat` / `type` from **original** location (not copied elsewhere) |
| Report | `OSCP-OS-XXXXX-Exam-Report.pdf` → password-free `.7z` under 200 MB → upload.offsec.com within 24h |

## Windows proof one-liner

```cmd
echo ==== & hostname & echo ==== & whoami & echo ==== & ipconfig /all & echo ==== & type C:\Users\Administrator\Desktop\proof.txt & type C:\Users\*\Desktop\local.txt 2>nul
```

```powershell
hostname; whoami; Get-NetIPAddress -AddressFamily IPv4 | ft; Get-ChildItem -Path C:\Users -Filter local.txt -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName; Get-Content $_.FullName }; Get-ChildItem -Path C:\Users\Administrator\Desktop\proof.txt -ErrorAction SilentlyContinue | ForEach-Object { Get-Content $_.FullName }
```

## Linux proof one-liner

```bash
echo '===='; hostname; echo '===='; id; echo '===='; ip -br a; echo '===='; \
  cat /home/*/local.txt 2>/dev/null; cat /root/proof.txt 2>/dev/null; \
  cat /root/local.txt 2>/dev/null
```

## Quick loot — Windows

```powershell
type (Get-PSReadlineOption).HistorySavePath
cmdkey /list
Get-ChildItem -Path C:\Users -Include *.txt,*.ini,*.config,*.xml,*.kdbx -File -Recurse -ErrorAction SilentlyContinue
```

```cmd
whoami /all
net user
net localgroup administrators
```

## Quick loot — Linux

```bash
sudo -l 2>/dev/null
cat ~/.bash_history 2>/dev/null
ls -la /home/*/.ssh 2>/dev/null
find /var/www -name '*.php' 2>/dev/null | head
env | grep -i pass
```

## Hash tags for loot.md

```text
type:ntlm       hashcat -m 1000
type:netntlmv2  hashcat -m 5600
type:tgs        hashcat -m 13100
type:asrep      hashcat -m 18200
type:pass       cleartext
type:ticket     ccache/kirbi
```
