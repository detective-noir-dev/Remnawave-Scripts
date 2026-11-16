---
aliases: ["Только Disk Swap"]
tags: [rw-helper]
тип: внутренняя функция
строка: 2891
файл: scripts.sh
---
# Только Disk Swap

`_mem_install_swap` · `scripts.sh` L2891

`_mem_install_swap <ГБ>` — останавливает ZRAM и удаляет `zram-tools`, пересоздаёт `/swapfile` нужного размера (`fallocate`, запасной вариант `dd`), `mkswap`, `swapon`, запись в fstab.

## Внешние команды и файлы
`/swapfile`

## Откуда вызывается
- [[submenu_memory]]
