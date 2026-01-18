# Remnawave-Scripts (English Version)

![version](https://img.shields.io/badge/version-1.2.4-blue)
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
- **📦 System package updates** ⭐ NEW in v1.2.3
  - Execute `apt update && apt upgrade -y` from menu
  - Confirmation before running
  - Support for apt and apt-get
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
| 4 | ⚙️ Maintenance | Check updates, **Update system packages** ⭐, Uninstall |

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

**Capabilities:**

1. **Open port**
   - Select port number (1-65535)
   - Choose protocol (TCP, UDP, or both)
   - Add description (e.g., "SSH server", "Web server")
   - Automatic firewall rule addition

2. **Close port**
   - View list of open ports
   - Select port to close
   - Automatic removal from firewall and database

3. **Edit description**
   - Change description of existing port
   - Useful for documenting port purposes

4. **List ports**
   ```
   ┌─────────┬───────────┬──────────────────────────────────────┐
   │ Port    │ Protocol  │ Description                          │
   ├─────────┼───────────┼──────────────────────────────────────┤
   │ 22      │ tcp       │ SSH server                           │
   │ 80      │ tcp       │ Web server (HTTP)                    │
   │ 443     │ tcp       │ Web server (HTTPS)                   │
   │ 3306    │ tcp       │ MySQL Database                       │
   └─────────┴───────────┴──────────────────────────────────────┘
   📊 Total open ports: 4
   ```

5. **Firewall status**
   - Shows firewall type in use (UFW/FirewallD/iptables)
   - Displays active rules
   - Shows overall protection status

**Supported firewalls:**
- ✅ **UFW** (Ubuntu/Debian)
- ✅ **FirewallD** (RHEL/CentOS/Fedora)
- ✅ **iptables** (universal for Linux)

---

#### 📦 System Package Updates (group 4 → option 2) ⭐ NEW in v1.2.3

**Maintenance submenu:**

```
╔════════════════════════════════════════════╗
║          ⚙️  Maintenance                  ║
╚════════════════════════════════════════════╝

1) 🔄 Check for updates
2) 📦 Update system packages    ⭐ NEW
3) 🗑️  Uninstall rw-scripts
0) ⬅️  Back
```

**Package update function:**
- Executes `apt update && apt upgrade -y`
- Asks for confirmation before running
- Automatically detects `apt` or `apt-get`
- Shows update progress in real-time
- Displays completion message

**Usage example:**
```
📦 Update system packages? This may take a while. (y/n)
> y

📦 Updating package lists...
Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
...

⬆️  Installing updates...
Reading package lists... Done
...

✅ All packages updated!
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

## 🔐 Security

When using the script:

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

**Version:** 1.2.2 
**Release Date:** January 2025  
**License:** MIT