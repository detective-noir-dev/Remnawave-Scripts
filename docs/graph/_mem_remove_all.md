---
aliases: ["Удалить ZRAM и Swap"]
tags: [rw-helper]
тип: внутренняя функция
строка: 143
файл: lib/memory.sh
---
# Удалить ZRAM и Swap

`_mem_remove_all` · `lib/memory.sh` L143

Останавливает и отключает `zramswap`, удаляет `zram-tools`, делает `swapoff -a`, удаляет `/swapfile` и его строку из fstab.

## Откуда вызывается
- [[submenu_memory]]
