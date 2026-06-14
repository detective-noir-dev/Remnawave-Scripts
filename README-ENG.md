# Remnawave-Scripts (English Version)

![version](https://img.shields.io/badge/version-1.4.1-blue)
![made-with-bash](https://img.shields.io/badge/made%20with-bash-green)
![license](https://img.shields.io/badge/license-MIT-green)

Remnawave-Scripts is a cross-platform Bash script with an interactive menu, dual language support (RU/EN), random ID generation, country search with emoji flags, and port management.

It also includes a self-update system from GitHub and allows you to uninstall the script (rw-scripts) directly from the menu.

---

## 📌 Features

- **Random shorts_id generation** — create unique identifiers
- **Country search** — search in Russian and English, supports partial matches
- **Show emoji flag** and English country name
- **💾 Memory Monitor** ⭐ v1.1.0
  - Display free and used RAM
  - Cross-platform support (Linux, macOS)
- **📈 Interactive Process Monitor (htop)** ⭐ v1.1.0
  - Automatic htop installation if needed
  - Real-time monitoring of processes, CPU, and memory
- **🔒 Port Management** ⭐ v1.2.0
  - 🔓 Open ports via firewall (UFW/FirewallD/iptables)
  - 🔒 Close ports and remove from database
  - ✏️ Edit port descriptions
  - 📋 Beautiful list of all open ports
  - 🛡️ View firewall status
  - 💾 Save port data between sessions
- **📦 System Package Update** ⭐ v1.2.3
  - Execute `apt update && apt upgrade -y` from the menu
  - Confirmation before running
  - Support for apt and apt-get
- **🖥️ Server Configuration** ⭐ v1.3.0
  - 🔑 Change SSH port
  - ⚡ Install, remove, and manage Hysteria2
- **🛡️ Zapret Installation** ⭐ v1.4.0
  - One-command installation directly from the menu
- **🔧 Third-party Scripts** ⭐ NEW in v1.4.1
  - 🌐 Quick installation of Remnawave by EGames
  - 🤖 Installation of Reshala (Remnawave Bedolaga)
  - Automatic environment variable handling (bashrc)
- **System Information** — display system data via neofetch
- **Language Switching**: Russian / English
- **Interactive CLI Menu**
- **GitHub Update System**
- **Uninstall Option**

---

## 🚀 Installation

Install with one command:

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

| # | Group | Content |
|---|--------|------------|
| 1 | 🆔 Short ID & Country Flags | Generate shorts_id, Get country emoji flag |
| 2 | 📊 Resource Monitor | Free memory, htop, System info (neofetch) |
| 3 | 🔐 Network & Ports | Port management submenu |
| 4 | ⚙️ Maintenance | Check updates, Update system packages, Uninstall |
| 5 | 🖥️ Server Configuration | SSH port, Zapret, Hysteria2 |
| 6 | 🔧 Third-party Scripts | Remnawave (EGames), Reshala |

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
- Sort by CPU/Memory
- Process management
- Color-coded data display

#### 🔒 Port Management (Group 3)

**Port Management Submenu:**

```
╔════════════════════════════════════════════╗
║      🔒 Port Management / Ports           ║
╚════════════════════════════════════════════╝

1) 🔓 Open Port
2) 🔒 Close Port
3) ✏️  Edit Description
4) 📋 List Ports
5) 🛡️  Firewall Status
0) ⬅️  Back
```

**Supported firewalls:**
- ✅ **UFW** (Ubuntu/Debian)
- ✅ **FirewallD** (RHEL/CentOS/Fedora)
- ✅ **iptables** (universal for Linux)

---

#### 🖥️ Server Configuration (Group 5) ⭐ v1.3.0

**Server Configuration Submenu:**

```
╔════════════════════════════════════════════╗
║         🖥️  Server Configuration          ║
╚════════════════════════════════════════════╝

1) 🔑 Change SSH Port
2) 🛡️  Install Zapret
3) ⚡ Hysteria2
0) ⬅️  Back
```

#### 🛡️ Zapret Installation (Group 5 → Item 2)

Runs zapret installation with one command directly from the menu without manual input.

#### ⚡ Hysteria2 (Group 5 → Item 3)

**Hysteria2 Submenu:**

```
╔════════════════════════════════════════════╗
║              ⚡ Hysteria2                 ║
╚════════════════════════════════════════════╝

1) ⚡ Install Hysteria2
2) 🗑️  Remove Hysteria2
3) 📝 Edit Config
4) ⚙️  Service Management
5) 📋 Logs
6) 🔍 Check Version
7) ⬆️  Update Hysteria2
0) ⬅️  Back
```

---

#### 🔧 Third-party Scripts (Group 6) ⭐ NEW in v1.4.1

**Third-party Scripts Submenu:**

```
╔════════════════════════════════════════════╗
║         🔧 Third-party Scripts            ║
╚════════════════════════════════════════════╝

1) 🌐 Remnawave (EGames)
2) 🤖 Reshala
0) ⬅️  Back
```

**What's included:**
- **🌐 Remnawave (EGames):** Automatic installation of the reverse-proxy solution by EGamesAPI. The script downloads the installer, runs it, and correctly updates environment variables.
- **🤖 Reshala:** Installation of the popular Reshala script by DonMatteoVPN. Includes secure download to a temporary file and auto-launch after installation.

> **⚠️ Important:** After installing third-party scripts, you may need to restart your terminal or run `source ~/.bashrc` to activate new commands. The script will automatically suggest this.

---

#### 📦 System Package Update (Group 4 → Item 2)

**Maintenance Submenu:**

```
╔════════════════════════════════════════════╗
║         ⚙️  Maintenance                   ║
╚════════════════════════════════════════════╝

1) 🔄 Check Updates
2) 📦 Update System Packages
3) 🗑️  Uninstall rw-scripts
0) ⬅️  Back
```

**Note:** The package update function is only available for Debian/Ubuntu-based systems.

---

## 🌍 Language Support

- Russian (Russian)
- English (English)

Language is selected during the first installation and saved in `~/.config/remnawave/lang.conf`

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
- **Dependencies** (installed automatically if needed):
  - `bash` — main interpreter
  - `curl` — for downloading updates
  - `xxd` — for ID generation (auto-install)
  - `neofetch` — for system info (optional)
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

## ⭐ Support the Project

If you like the project, give it a star on GitHub! 🌟

---

## 🔐 Security

**Port Management:**
- ⚠️ Requires sudo privileges for firewall operations
- 🛡️ All changes are applied directly to the system firewall
- 💾 Port data is stored locally in your home directory
- 🔒 Recommended to open only necessary ports

**System Package Updates:**
- ⚠️ Requires sudo privileges for package installation
- 📦 Performs a full system update
- ⏱️ Process may take significant time
- 🔄 Recommended to perform regularly for system security

**Third-party Scripts:**
- ⚠️ Scripts are downloaded from external repositories (EGamesAPI, DonMatteoVPN)
- 🛡️ It is recommended to review the source code of third-party scripts before running
- 🔒 Use at your own risk

---

**Version:** 1.4.1
**Release Date:** June 2026
**License:** MIT
```