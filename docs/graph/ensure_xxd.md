---
aliases: ["Установка xxd"]
tags: [rw-func]
тип: действие
строка: 6
файл: lib/ids.sh
---
# Установка xxd

`ensure_xxd` · `lib/ids.sh` L6

Если нет `xxd` — ставит `vim-xxd` (или `xxd` на apt) через найденный пакетный менеджер. Возвращает 0/1.

## Внешние команды и файлы
`apt/dnf/yum/pacman/zypper/brew`

## Откуда вызывается
- [[generate_ids]]
