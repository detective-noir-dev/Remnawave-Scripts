# Remnawave-Scripts

🇷🇺 [Русская версия](README.md) (main document)

![version](https://img.shields.io/badge/version-1.12.9-blue)
![made-with-bash](https://img.shields.io/badge/made%20with-bash-green)
![license](https://img.shields.io/badge/license-MIT-green)

Remnawave-Scripts is a Bash script with an interactive menu for setting up and maintaining a Linux server, including a Remnawave node: SSH, ports and firewall, Hysteria2, Cloudflare WARP, a SOCKS5 proxy, cleanup, swap, and domain search for Reality. The interface is available in Russian and English.

---

## 🆕 What's new

**1.12.9 — major bug-fix release**
- Disabling SSH password login works again.
- Adding an SSH key no longer corrupts an `authorized_keys` file that has no trailing newline.
- Changing the SSH port supports `ssh.socket` and checks that the new port is listening.
- The port list no longer shows ufw deny and outbound rules as open ports.
- Fixes in Dante, Hysteria2 for Remnanode, WARP, the scanner and package upgrades.

**1.12.0–1.12.8 — SSH management from the menu**
- Add an `ed25519` public key, with validation and a confirmation before replacing keys.
- Disable password login: only when a key is present, with config checks and rollback on failure.
- Edit `sshd_config` with a syntax check and restore from backup.

**1.11.0 — Dante SOCKS5 proxy** restricted to allowed IP addresses.

Full history: [CHANGELOG.md](CHANGELOG.md) (in Russian) and [GitHub releases](https://github.com/detective-noir-dev/Remnawave-Scripts/releases).

---

## 🚀 Installation

```bash
bash <(curl -s https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main/install.sh)
```

Run:

```bash
rw-scripts
```

The installer asks for a language on the first run. If `~/.local/bin` was not in your `PATH`, open a new terminal after installation.

**Updating:** menu item `4 → 1`. The previous version is saved before an update; go back to it with `4 → 6` or `rw-scripts rollback`.

---

## 📁 Menu

| # | Group | Content |
|---|-------|---------|
| 1 | 🆔 Short ID & Country Flags | Generate shorts_id, get a country's emoji flag and English name |
| 2 | 📊 Resource Monitor | Memory, htop, system info (neofetch) |
| 3 | 🔐 Network & Ports | Open and close ports, descriptions, firewall status |
| 4 | ⚙️ Maintenance | Update and rollback, system packages, cleanup, memory, scanner, uninstall |
| 5 | 🖥️ Server Setup | SSH, zapret, Hysteria2, Cloudflare WARP, Dante |
| 6 | 🔧 Third-party Scripts | Remnawave (EGames), Reshala, Multitest |
| 0 | 🚪 Exit | |

### 📊 Dashboard

A short summary is shown above the main menu. Example (made-up values):

```
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🚀 REMNAWAVE-SCRIPTS  vX.Y.Z · English
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SYS  Ubuntu 24.04 LTS · KVM · kernel 6.8.0
  NET  203.0.113.10 · ping 12.5 ms ⚡ · up 3d 14h 5m
  SVC  ✔ ssh  ✔ ufw  ✔ docker  ✖ hy2
  ──────────────────────────────────────────────
  CPU  █░░░░░░░░░░░  12%  4 vCPU
  RAM  ████░░░░░░░░  35%  1.4G / 3.8G
  NVMe ██████░░░░░░  55%  14G / 25G
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

The `SVC` line lists only the installed services among: ssh, ufw, docker, Hysteria2, WARP, fail2ban, Dante.

---

## 📌 Features

### 🆔 Short ID & Country Flags
- Generate any number of `shorts_id` values (16 hex characters).
- Find a country by part of its Russian or English name.

### 🔐 Network & Ports
- Supports **UFW**, **FirewallD** and **iptables**.
- Open and close TCP, UDP, or both.
- The port list is synced with the firewall; descriptions are stored in `~/.local/share/remnawave/ports.json`.

### 🖥️ Server Setup

| Item | What it does |
|------|--------------|
| 🔑 Change SSH port | Port 1024–65535: edits the config, opens the port in the firewall, restarts SSH; restores the previous config on failure |
| 🔐 Add ed25519 key | Validates the key and adds it to `authorized_keys`; replaces other ed25519 keys only after you confirm |
| 🚫 Disable password login | Requires an SSH key to be present; checks the config and rolls back on failure |
| 📝 Edit SSH config | Opens `sshd_config` in an editor and checks it before restarting SSH |
| 🛡️ zapret | Runs a third-party installer |
| ⚡ Hysteria2 | Install, remove, config, service, logs, version, update; Remnanode setup |
| ☁️ Cloudflare WARP | Install, status, connect, disconnect, uninstall |
| 🧦 Dante | SOCKS5 proxy: install, allowed IP list, status, restart, logs, remove |

> ⚠️ When changing SSH settings, keep your current session open and test the login in a second one.

**Hysteria2 for Remnanode** prepares an Xray inbound: it mounts a Let's Encrypt certificate in `docker-compose.yml`, creates a restart hook for certificate renewal and opens the UDP port. It needs root, `/opt/remnanode/docker-compose.yml` and an already issued certificate.

**Cloudflare WARP** is installed as a SOCKS5 proxy on `127.0.0.1:<port>` (default 40000). Ubuntu or Debian and root are required. To use it: `export ALL_PROXY=socks5://127.0.0.1:<port>`.

**Dante** accepts only the IP addresses you list (default port 1080). The proxy has no password, and SOCKS5 does not encrypt traffic by itself. If the server's IP changes, restart the service: the status screen tells you when this is needed.

### 🧹 System Cleaner (`4 → 3`)
- Everything at once or by category: APT, journald, Docker, temporary files, old Snap revisions.
- Shows how much space was freed.
- Disk analyzer: browse large files; you can truncate them in `/var/log` and delete them in the APT cache and `/tmp`.

> ⚠️ Full cleanup truncates log files in `/var/log` and Docker container logs, and deletes everything in `/tmp`, `/var/tmp` and `~/.cache`. Docker cleanup removes unused images, containers, networks and **volumes**, so it asks for a separate confirmation.

### 🧠 Memory & Swap (`4 → 4`)
- Hybrid mode (ZRAM plus a disk swap file), ZRAM only, or swap only.
- Recommendations based on RAM size, detailed status, example Docker memory limits.
- The "ZRAM only", "swap only" and "disable" options remove the existing `/swapfile`.

### 🔍 Reality TLS Scanner (`4 → 5`)
- Find SNI domains for VLESS+Reality: a single target or a list of targets.
- Results are ranked by certificate issuer; reports are saved as CSV.
- Installs Go, builds [RealiTLScanner](https://github.com/XTLS/RealiTLScanner) and downloads the GeoIP database.

### 🔧 Third-party Scripts
- **Remnawave (EGames)** — a reverse-proxy solution by eGamesAPI.
- **Reshala** — a script by DonMatteoVPN.
- **Multitest** — a tool by saveksme, installed to `/usr/local/bin/multitest`.

After installing them you may need a new terminal or `source ~/.bashrc`.

---

## ⌨️ Commands without the menu

For cron, monitoring, CI and bug reports:

```bash
rw-scripts help               # list of commands
rw-scripts status             # state of installed services
rw-scripts ports              # open ports
rw-scripts ports open 443/tcp # open a port; without /tcp or /udp, both protocols
rw-scripts ports close 443/tcp
rw-scripts warp status        # or connect / disconnect
rw-scripts hy2 restart        # or status / start / stop / enable / logs / version
rw-scripts clean              # full cleanup; in a terminal it asks only about Docker, from cron Docker is skipped
rw-scripts doctor [--online]  # check dependencies, privileges, modules and repository access
rw-scripts rollback [--yes]   # go back to the version before the last update
rw-scripts config set lang en # settings: lang (ru|en), color (auto|always|never)
rw-scripts log 20             # last lines of the action log
rw-scripts completion bash    # shell completion (bash or zsh); the installer sets up bash
rw-scripts version            # print version
```

Colors are turned off by the `NO_COLOR` variable, and automatically when output is not a terminal.

---

## 🔐 Security

- **Privileges:** changing the system requires root or `sudo`.
- **Third-party scripts** (zapret, Hysteria2, eGames, Reshala, Multitest) are first downloaded to a temporary file. The script shows the size and SHA256 and asks for confirmation (`v` to view the content). A copy is kept in `~/.local/share/remnawave/third-party/`. This is someone else's code: review it before running.
- **Ports:** open only what you need — changes apply to the system firewall immediately.
- **Package upgrade** (`4 → 2`) asks no questions during installation: config files you have modified are kept.

---

## 📦 System Requirements

- **OS:** Linux. The main target is Ubuntu and Debian with systemd. Memory management, package upgrade and WARP expect an `apt`-based system; other features may be incomplete on other systems.
- **Required:** `bash`, `curl`.
- **Installed when needed:** `jq` (ports), `xxd` (ID generation), `htop` and `neofetch` (monitor).
- **For port management:** `ufw`, `firewalld` or `iptables`.

CI tests the script on Ubuntu 22.04 and 24.04, Debian 12 and Alpine 3.20 (the Alpine job does not block the build).

---

## ⚙️ Uninstallation

From the menu: item `4 → 7`. Or directly:

```bash
~/.local/share/remnawave/uninstall.sh
```

This removes the script, its data and settings. Anything you installed or changed on the server through it (Hysteria2, WARP, SSH and firewall settings) stays.

---

## 🌍 Language

Russian and English. Chosen during the first installation and stored in `~/.config/remnawave/config`. To change it: `rw-scripts config set lang en` (or `ru`).

---

## 🛠️ Repository Structure

- **scripts.sh** — core: settings, language, module loading, entry point
- **lib/** — modules by topic: `menus.sh` (menus and dashboard), `server.sh` (SSH, zapret), `firewall.sh`, `hy2.sh`, `warp.sh`, `dante.sh`, `cleaner.sh`, `memory.sh`, `scanner.sh`, `maintenance.sh`, `thirdparty.sh`, `system.sh`, `ids.sh`, `cli.sh` (commands without the menu), `doctor.sh`, `common.sh`, `pkg.sh`
- **lang/** — UI dictionaries (`ru.sh`, `en.sh`)
- **docs/graph/** — function map for Obsidian (in Russian)
- **tests/**, **tools/**, **.githooks/** — tests (`bash tests/run.sh`, bats in `tests/bats`), helper scripts and git hooks
- **install.sh**, **uninstall.sh** — installer and uninstaller
- **countries.csv** — country database (RU/EN and ISO code)
- **version.txt**, **CHANGELOG.md** — version and change history
- **SHA256SUMS** — checksums for updating from older versions
- **README.md** — main document, **README-ENG.md** — its translation

---

## 👨‍💻 Author

Created by **detective-noir-dev** — [Remnawave-Scripts](https://github.com/detective-noir-dev/Remnawave-Scripts)

If you find the project useful, give it a star on GitHub! 🌟

---

**Version:** 1.12.9
**Release Date:** November 2026
**License:** MIT
