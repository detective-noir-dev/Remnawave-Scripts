---
aliases: ["Свободная память"]
tags: [rw-func]
тип: действие
строка: 39
файл: lib/system.sh
---
# Свободная память

`show_memory` · `lib/system.sh` L39

Показывает память: `free -h`. Запасные варианты: `vm_stat` на macOS или разбор `/proc/meminfo` через awk, если `free` отсутствует.

## Внешние команды и файлы
`free`, `vm_stat`, `/proc/meminfo`

## Откуда вызывается
- [[submenu_monitor]]
