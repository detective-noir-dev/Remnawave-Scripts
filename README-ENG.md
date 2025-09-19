Remnawave-Scripts (English)

![version](https://img.shields.io/badge/version-0.0.7-blue)
![made-with-bash](https://img.shields.io/badge/made%20with-bash-green)

Remnawave-Scripts is a cross‑platform Bash script with an interactive menu, multilingual support (RU/EN), random ID generation and country lookup with emoji flags.

It also includes a self‑update system from GitHub and allows uninstalling the script (rw-scripts) from the menu.

📌 Features
Generate random shorts_id
Country lookup (search in Russian and English, partial matches supported)
Show emoji flag and English name of the country
Language switch: Русский / English
Interactive CLI menu
GitHub‑based update system
Option to uninstall from system
🚀 Installation
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

📖 Usage
Example menu:
===============================
1) Generate shorts_id
2) Find country flag
3) Check version/update
4) Uninstall rw-scripts
9) Change language
0) Exit
🛠️ Repository structure
scripts.sh — main script
install.sh — installer
countries.csv — dataset of countries (RU/EN + ISO)
version.txt — current version
README.md — project description