# Terminal cheatsheets — arsenal-ng

**Recommended CLI launcher:** [halilkirazkaya/arsenal-ng](https://github.com/halilkirazkaya/arsenal-ng)

Modern Go rewrite of Orange Cyberdefense **arsenal**: fuzzy search across 200+ tool cheatsheets, argument placeholders, global variables, command prefilled into the terminal.

## Why use it

| Problem | arsenal-ng |
|---------|------------|
| Scrolling a 600-line markdown dump mid-exam | Fuzzy search (`nmap`, `kerberoast`, `evil-winrm`) |
| Rewriting IPs every time | `set lhost=…` / `set ip=…` globals |
| Typos under fatigue | Edit prefilled line, then Enter |
| Markdown is for study | arsenal-ng is for **execution** |

Use **this repo’s markdown** to learn; use **arsenal-ng** to fire commands.

## Install

### Go install

```bash
go install -v github.com/halilkirazkaya/arsenal-ng/cmd/arsenal-ng@latest
# ensure $(go env GOPATH)/bin is on PATH
```

### Build from source

```bash
git clone https://github.com/halilkirazkaya/arsenal-ng.git
cd arsenal-ng
make build
./bin/arsenal-ng
```

### Handy alias

```bash
echo "alias a='arsenal-ng'" >> ~/.bashrc
source ~/.bashrc
```

### Platform notes

| Platform | Status |
|----------|--------|
| Linux | Supported (kernel 6.2+ may need TIOCSTI for terminal prefill — see upstream README) |
| macOS | Supported |
| Windows | WSL only |

If prefill fails on modern Linux:

```bash
# temporary
sudo sysctl -w dev.tty.legacy_tiocsti=1
```

Or see upstream `setcap` / sysctl options (understand security trade-offs).

## Exam/lab workflow

```bash
# 1. Start
a   # or arsenal-ng

# 2. Set session globals (type in search box, Enter)
set lhost=192.168.x.x
set ip=10.10.10.10
set domain=corp.local
set user=bob
set pass='Something'
set wordlist=/usr/share/wordlists/rockyou.txt

# 3. Search
nmap
nxc
kerberoast
evil-winrm

# 4. Select → fill remaining args → command lands in shell → edit → run
```

### Useful special commands (in-app)

| Command | Effect |
|---------|--------|
| `set key=value` | Global variable |
| `unset key` | Remove variable |
| `variables` | List globals |
| `tools` | Browse tools table |
| `?` / `help` | Help |

## Personal cheats (optional)

Upstream YAML format (for forks/PRs or local builds):

```yaml
tool: personal-oscp
tags: [oscp, personal]

actions:
  - title: proof - windows
    desc: Identity + proof flag
    command: "hostname & whoami & ipconfig /all & type C:\\Users\\Administrator\\Desktop\\proof.txt"

  - title: proof - linux
    desc: Identity + proof flag
    command: "hostname; id; ip -br a; cat /root/proof.txt 2>/dev/null"

  - title: nxc - spray pass
    desc: Spray a password across targets
    command: "nxc smb {{targets}} -u {{user}} -p '{{pass}}' --continue-on-success"

  - title: history - psreadline
    desc: PowerShell history path
    command: "type (Get-PSReadlineOption).HistorySavePath"
```

Add under `internal/loader/cheat-files/` in a **local fork**, rebuild, keep private if notes are personal.

This repo does **not** vendor arsenal-ng; install it on the attack VM.

## Relationship to `cheatsheets/`

| Source | When |
|--------|------|
| [cheatsheets/](../cheatsheets/) | Reading, reviewing, git, no TUI |
| arsenal-ng built-ins | Most nmap/ffuf/impacket-style commands |
| Your personal YAML | OSCP proof one-liners, NetExec habits, custom aliases |

After learning a new command in a lab:

1. Add it to the right markdown cheatsheet (if worth studying)  
2. Optionally add YAML action for arsenal-ng  
3. Do **not** append to a new mega-`command.md` dump  

## Upstream

- Repo: https://github.com/halilkirazkaya/arsenal-ng  
- Inspired by: https://github.com/Orange-Cyberdefense/arsenal  
