---
aliases: ["Свободная память"]
tags: [rw-func]
тип: действие
строка: 548
файл: scripts.sh
---
# Свободная память

`show_memory` · `scripts.sh` L548

Показывает память: `free -h`. Запасные варианты: `vm_stat` на macOS или разбор `/proc/meminfo` через awk, если `free` отсутствует.

## Внешние команды и файлы
`free`, `vm_stat`, `/proc/meminfo`

## Откуда вызывается
- [[submenu_monitor]]
