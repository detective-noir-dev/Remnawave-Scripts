---
aliases: ["Установщик / обновлятор"]
tags: [rw-file]
тип: файл репозитория
---
# Установщик / обновлятор

`install.sh` · файл в корне репозитория

Ставит и обновляет `rw-scripts`. Запускается через `curl | bash`.

## Что происходит
1. `check_and_install_sudo` — если нет sudo, ставит его (apt/dnf/yum/pacman/zypper/apk); не root — подсказывает команду
2. скачивает `version.txt` и сравнивает с установленной → «Fresh install» или «Update x → y»
3. если нет `lang.conf` — спрашивает язык (1 English / 2 Русский)
4. скачивает `scripts.sh` → `~/.local/bin/rw-scripts`, `uninstall.sh`, `countries.csv` в `DATA_DIR`
5. добавляет `~/.local/bin` в PATH (`.bashrc`/`.zshrc`/`.profile`), если его нет
6. печатает итог на выбранном языке

## Внешние команды и файлы
`curl`, `sudo`, `~/.bashrc`

## Откуда вызывается
- [[Окружение]]
