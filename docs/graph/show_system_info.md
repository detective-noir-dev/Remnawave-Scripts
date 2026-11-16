---
aliases: ["Системная информация"]
tags: [rw-func]
тип: действие
строка: 6
файл: lib/system.sh
---
# Системная информация

`show_system_info` · `lib/system.sh` L6

Запускает `neofetch`. Если его нет — предлагает установить (y/n) под спиннером (apt/dnf/yum/pacman/zypper/brew).

## Использует (общие хелперы)
`loading_bar`

## Внешние команды и файлы
`neofetch`

## Откуда вызывается
- [[submenu_monitor]]
