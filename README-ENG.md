# Remnawave-Scripts (English)

![version](https://img.shields.io/badge/version-1.2.1-blue)
![made-with-bash](https://img.shields.io/badge/made%20with-bash-green)
![license](https://img.shields.io/badge/license-MIT-green)

Remnawave-Scripts is a cross-platform Bash script with an interactive menu, multilingual support (RU/EN), random ID generation, country lookup with emoji flags, and port management.

It also includes a self-update system from GitHub and allows uninstalling the script (rw-scripts) from the menu.

---

## 📌 Features

- **Generate random shorts_id** — create unique identifiers
- **Country lookup** — search in Russian and English, partial matches supported
- **Show emoji flag** and English name of the country
- **💾 Memory monitoring** ⭐ v1.1.0
  - Display free and used RAM
  - Cross-platform support (Linux, macOS)
- **📈 Interactive process monitor (htop)** ⭐ v1.1.0
  - Automatic htop installation when needed
  - Real-time process, CPU, and memory monitoring
- **🔒 Port management** ⭐ NEW in v1.2.0
  - 🔓 Open ports through firewall (UFW/FirewallD/iptables)
  - 🔒 Close ports with database removal
  - ✏️ Edit port descriptions
  - 📋 Beautiful list of all open ports
  - 🛡️ View firewall status
  - 💾 Save port data between sessions
- **System information** — display system data via neofetch
- **Language switch**: Русский / English
- **Interactive CLI menu**
- **GitHub-based update system**
- **Option to uninstall** from system

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
# Choose option 4 (Uninstall rw-scripts)
```

Or directly:

```bash
~/.local/share/remnawave/uninstall.sh
```

---

## 📖 Usage

📁 Menu Groups
#	Group	Contents
1	🆔 Short ID & Country Flags	Generate shorts_id, Get country emoji flag
2	📊 Resource Monitor	Free memory, htop, System info (neofetch)
3	🔐 Network & Ports	Port management submenu
4	⚙️ Maintenance	Check updates, Uninstall

```

### Usage Examples

#### 💾 Memory Monitoring (option 5)
Displays information about:
- Total memory
- Used memory
- Free memory
- Cached memory

#### 📈 Process Monitor (option 6)
- Interactive htop interface
- Sort by CPU/memory
- Process management
- Colored data display

#### 🔒 Port Management (option 8) ⭐ NEW in v1.2.0

**Port Management Submenu:**

```
╔════════════════════════════════════════════╗
║      🔒 Управление портами / Ports        ║
╚════════════════════════════════════════════╝

1) 🔓 Открыть порт / Open port
2) 🔒 Закрыть порт / Close port
3) ✏️  Редактировать описание / Edit description
4) 📋 Список портов / List ports
5) 🛡️  Статус firewall / Firewall status
0) ⬅️  Назад / Back
```

**Capabilities:**

1. **Open Port**
   - Choose port number (1-65535)
   - Select protocol (TCP, UDP, or both)
   - Add description (e.g., "SSH server", "Web server")
   - Automatic rule addition to firewall

2. **Close Port**
   - View list of open ports
   - Select port to close
   - Automatic removal from firewall and database

3. **Edit Description**
   - Change description of existing port
   - Useful for documenting port purposes

4. **List Ports**
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

5. **Firewall Status**
   - Shows type of firewall in use (UFW/FirewallD/iptables)
   - Displays active rules
   - Shows overall security status

**Supported Firewalls:**
- ✅ **UFW** (Ubuntu/Debian)
- ✅ **FirewallD** (RHEL/CentOS/Fedora)
- ✅ **iptables** (universal for Linux)

**Automatic Dependencies:**
- `jq` is automatically installed on first use for JSON handling

**Data Storage:**
- All ports are saved in `~/.local/share/remnawave/ports.json`
- Data persists across reboots
- Each port has a creation timestamp

---

## 🌍 Language Support

- Русский (Russian)
- English

Language is selected during first installation and saved in `~/.config/remnawave/lang.conf`

---

## 🛠️ Repository Structure

- **scripts.sh** — main script
- **install.sh** — installer (copies to ~/.local/bin/rw-scripts)
- **uninstall.sh** — uninstaller
- **countries.csv** — dataset of countries (RU/EN + ISO)
- **version.txt** — current version
- **README.md** — project description (RU)
- **README-ENG.md** — project description (EN)

---

## 📦 System Requirements

- **OS**: Linux, macOS, BSD, Windows WSL
- **Dependencies** (installed automatically when needed):
  - `bash` — main interpreter
  - `curl` — for downloading updates
  - `xxd` — for ID generation (auto-installed)
  - `neofetch` — for system information (optional)
  - `htop` — for process monitor (optional)
  - `jq` — for JSON handling in port management (auto-installed)
  - `ufw` / `firewalld` / `iptables` — firewall for port management

---

## 🔄 Version History

### v1.2.0 (Current) - January 17, 2025
- ✅ Added port management (open/close/edit)
- ✅ Support for UFW, FirewallD, and iptables
- ✅ Save port data in JSON with descriptions
- ✅ Automatic jq installation
- ✅ Beautiful tables for port display
- ✅ Firewall status and rule checking
- ✅ Improved user interface

### v1.1.0
- ✅ Added free memory monitoring
- ✅ Added interactive process monitor (htop)
- ✅ Automatic dependency installation
- ✅ Improved cross-platform compatibility

### v1.0.4
- Basic ID generation functionality
- Country search with flags
- Auto-update system
- Multilingual support (RU/EN)

---

## 🤝 Contributing

If you found a bug or want to suggest a new feature:
1. Open an Issue on GitHub
2. Create a Pull Request
3. Write in Discussions section

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

When using port management:
- ⚠️ Sudo privileges required for firewall operations
- 🛡️ All changes are applied directly to system firewall
- 💾 Port data is stored locally in your home directory
- 🔒 Recommended to open only necessary ports

---

## 📚 Useful Links

- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [FirewallD Documentation](https://firewalld.org/)
- [iptables Guide](https://www.netfilter.org/documentation/)

---

**Version:** 1.2.0  
**Release Date:** January 17, 2025  
**License:** MIT