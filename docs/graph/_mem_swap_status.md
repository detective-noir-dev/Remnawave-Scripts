---
aliases: ["Краткий статус swap"]
tags: [rw-helper]
тип: внутренняя функция
строка: 5
файл: lib/memory.sh
---
# Краткий статус swap

`_mem_swap_status` · `lib/memory.sh` L5

Одной строкой: `[ГИБРИД: ZRAM + Disk Swap]`, `[ZRAM: N MB]`, `[Disk Swap: N MB]` или `[ВЫКЛЮЧЕН]`. Определяет по `lsblk` и `swapon --show`.

## Откуда вызывается
- [[submenu_memory]]
