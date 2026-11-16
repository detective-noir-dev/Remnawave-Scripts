---
aliases: ["Удалить ZRAM и Swap"]
tags: [rw-helper]
тип: внутренняя функция
строка: 2908
файл: scripts.sh
---
# Удалить ZRAM и Swap

`_mem_remove_all` · `scripts.sh` L2908

Останавливает и отключает `zramswap`, удаляет `zram-tools`, делает `swapoff -a`, удаляет `/swapfile` и его строку из fstab.

## Откуда вызывается
- [[submenu_memory]]
