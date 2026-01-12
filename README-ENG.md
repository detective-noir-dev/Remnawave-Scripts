# Remnawave-Scripts (English)

![version](https://img.shields.io/badge/version-1.1.0-blue)
![made-with-bash](https://img.shields.io/badge/made%20with-bash-green)

Remnawave-Scripts is a cross‑platform Bash script with an interactive menu, multilingual support (RU/EN), random ID generation and country lookup with emoji flags.

It also includes a self‑update system from GitHub and allows uninstalling the script (rw-scripts) from the menu.

---

## 📌 Features

- **Generate random shorts_id** — create unique identifiers
- **Country lookup** — search in Russian and English, partial matches supported
- **Show emoji flag** and English name of the country
- **💾 Memory monitoring** ⭐ NEW in v1.1.0
  - Display free and used RAM
  - Cross-platform support (Linux, macOS)
- **📈 Interactive process monitor (htop)** ⭐ NEW in v1.1.0
  - Automatic htop installation when needed
  - Real-time process, CPU, and memory monitoring
- **System information** — display system data via neofetch
- **Language switch**: Русский / English
- **Interactive CLI menu**
- **GitHub‑based update system**
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

## ⚙️ Uninstallation

If you no longer need **Remnawave Scripts**, you can remove it with a single command:
```bash
./uninstall.sh
```

## 📖 Usage

Example menu:

```
===============================
1) Generate shorts_id
2) Find country flag
3) Check version/update
4) Uninstall rw-scripts
5) Show free memory              ⭐ NEW
6) Launch htop                   ⭐ NEW
7) Show system info
0) Exit
===============================
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

---

## 🌍 Language Support

- Русский (Russian)
- English

Language is selected during first installation and saved in `~/.config/remnawave/lang.conf`

---

## 🛠️ Repository structure

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

---

## 🔄 Version History

### v1.1.0 (Current)
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