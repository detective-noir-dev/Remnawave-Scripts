# Remnawave-Scripts (English Version)

![version](https://img.shields.io/badge/version-1.4.0-blue)
![made-with-bash](https://img.shields.io/badge/made%20with-bash-green)
![license](https://img.shields.io/badge/license-MIT-green)

Remnawave-Scripts is a cross-platform Bash script with an interactive menu, bilingual support (RU/EN), random ID generation, country search with emoji flags, and port management.

It also includes a self-update system from GitHub and allows you to uninstall the script (rw-scripts) directly from the menu.

---

## 📌 Features

- **Random shorts_id generation** — create unique identifiers
- **Country search** — search in Russian and English, partial matches supported
- **Display emoji flag** and English country name
- **💾 Memory monitoring** ⭐ v1.1.0
  - Display free and used RAM
  - Cross-platform support (Linux, macOS)
- **📈 Interactive process monitor (htop)** ⭐ v1.1.0
  - Automatic htop installation if needed
  - Real-time process, CPU, and memory monitoring
- **🔒 Port management** ⭐ v1.2.0
  - 🔓 Open ports via firewall (UFW/FirewallD/iptables)
  - 🔒 Close ports with database removal
  - ✏️ Edit port descriptions
  - 📋 Beautiful list of all open ports
  - 🛡️ View firewall status
  - 💾 Port data persistence between sessions
- **📦 System package updates** ⭐ v1.2.3
  - Execute `apt update && apt upgrade -y` from menu
  - Confirmation before running
  - Support for apt and apt-get
- **🖥️ Server Setup** ⭐ v1.3.0
  - 🔑 Change SSH port
  - ⚡ Install, remove and manage Hysteria2
- **🛡️ Install zapret** ⭐ NEW in v1.4.0
  - One-click install directly from the menu
- **System information** — display system data via neofetch
- **Language switching**: Russian / English
- **Interactive CLI menu**
- **Update system via GitHub**
- **Uninstall capability** from system

---

## 🚀 Installation

One-command installation:

```bash
bash <(curl -s https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main/install.sh)
```

Run globally:

```bash
rw-scripts
```

---

## ⚙️ Uninstallation

If you no longer need **Remnawave Scripts**, you can remove it:

```bash
rw-scripts
# Select option 4 → 3 (Uninstall rw-scripts)
```

Or directly:

```bash
~/.local/share/remnawave/uninstall.sh
```

---

## 📖 Usage

### 📁 Menu Groups

| # | Group | Contents |
|---|-------|----------|
| 1 | 🆔 Short ID & Country Flags | Generate shorts_id, Get country emoji flag |
| 2 | 📊 Resource Monitor | Free memory, htop, System information (neofetch) |
| 3 | 🔐 Network & Ports | Port management submenu |
| 4 | ⚙️ Maintenance | Check updates, Update system packages, Uninstall |
| 5 | 🖥️ Server Setup | SSH port, Zapret, Hysteria2 |

---

### Usage Examples

#### 💾 Memory Monitoring
Displays information about:
- Total memory
- Used memory
- Free memory
- Cached memory

#### 📈 Process Monitor
- Interactive htop interface
- Sort by CPU/memory
- Process management
- Color-coded display

#### 🔒 Port Management (group 3)

**Port management submenu:**

```
╔════════════════════════════════════════════╗
║       🔒 Port Management / Ports          ║
╚════════════════════════════════════════════╝

1) 🔓 Open port
2) 🔒 Close port
3) ✏️  Edit description
4) 📋 List ports
5) 🛡️  Firewall status
0) ⬅️  Back
```

**Supported firewalls:**
- ✅ **UFW** (Ubuntu/Debian)
- ✅ **FirewallD** (RHEL/CentOS/Fedora)
- ✅ **iptables** (universal for Linux)

---

#### 🖥️ Server Setup (group 5) ⭐ v1.3.0

**Server Setup submenu:**

```
╔════════════════════════════════════════════╗
║           🖥️  Server Setup               ║
╚════════════════════════════════════════════╝

1) 🔑 Change SSH port
2) 🛡️  Install zapret          ⭐ NEW in v1.4.0
3) ⚡ Hysteria2
0) ⬅️  Back
```

#### 🛡️ Install zapret (group 5 → option 2) ⭐ NEW in v1.4.0

Runs the zapret installer with a single menu selection — no manual commands needed.

#### ⚡ Hysteria2 (group 5 → option 3)

**Hysteria2 submenu:**

```
╔════════════════════════════════════════════╗
║              ⚡ Hysteria2                 ║
╚════════════════════════════════════════════╝

1) ⚡ Install Hysteria2
2) 🗑️  Remove Hysteria2
3) 📝 Edit config
4) ⚙️  Manage service
5) 📋 Logs
6) 🔍 Check version
7) ⬆️  Update Hysteria2
0) ⬅️  Back
```

---

#### 📦 System Package Updates (group 4 → option 2)

**Maintenance submenu:**

```
╔════════════════════════════════════════════╗
║          ⚙️  Maintenance                  ║
╚════════════════════════════════════════════╝

1) 🔄 Check for updates
2) 📦 Update system packages
3) 🗑️  Uninstall rw-scripts
0) ⬅️  Back
```

**Note:** This feature is only available for Debian/Ubuntu-based systems with the apt package manager.

---

## 🌍 Language Support

- Russian (Русский)
- English

Language is selected during first installation and saved in `~/.config/remnawave/lang.conf`

---

## 🛠️ Repository Structure

- **scripts.sh** — main script
- **install.sh** — installer (copies to ~/.local/bin/rw-scripts)
- **uninstall.sh** — uninstaller
- **countries.csv** — country database (RU/EN + ISO)
- **version.txt** — current version
- **README.md** — project description (RU)
- **README-ENG.md** — project description (EN)

---

## 📦 System Requirements

- **OS**: Linux, macOS, BSD, Windows WSL
- **Dependencies** (installed automatically when needed):
  - `bash` — main interpreter
  - `curl` — for downloading updates
  - `xxd` — for ID generation (auto-install)
  - `neofetch` — for system information (optional)
  - `htop` — for process monitor (optional)
  - `jq` — for JSON handling in port management (auto-install)
  - `ufw` / `firewalld` / `iptables` — firewall for port management
  - `apt` / `apt-get` — for system package updates (Debian/Ubuntu)

---

## 📝 License

MIT License

---

## 👨‍💻 Author

Created by **detective-noir-dev**

GitHub: [Remnawave-Scripts](https://github.com/detective-noir-dev/Remnawave-Scripts)

---

## ⭐ Support the project

If you like the project, give it a star on GitHub! 🌟

---

## 🔐 Security

**Port management:**
- ⚠️ Sudo privileges required for firewall operations
- 🛡️ All changes are applied directly to the system firewall
- 💾 Port data is stored locally in your home directory
- 🔒 It is recommended to open only necessary ports

**System package updates:**
- ⚠️ Sudo privileges required for package installation
- 📦 Performs full system update
- ⏱️ Process may take significant time
- 🔄 Recommended to run regularly for system security

---

**Version:** 1.4.0
**Release Date:** May 2026
**License:** MIT