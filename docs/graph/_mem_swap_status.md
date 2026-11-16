---
aliases: ["Краткий статус swap"]
tags: [rw-helper]
тип: внутренняя функция
строка: 2773
файл: scripts.sh
---
# Краткий статус swap

`_mem_swap_status` · `scripts.sh` L2773

Одной строкой: `[ГИБРИД: ZRAM + Disk Swap]`, `[ZRAM: N MB]`, `[Disk Swap: N MB]` или `[ВЫКЛЮЧЕН]`. Определяет по `lsblk` и `swapon --show`.

## Откуда вызывается
- [[submenu_memory]]
