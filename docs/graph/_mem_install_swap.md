---
aliases: ["Только Disk Swap"]
tags: [rw-helper]
тип: внутренняя функция
строка: 132
файл: lib/memory.sh
---
# Только Disk Swap

`_mem_install_swap` · `lib/memory.sh` L132

`_mem_install_swap <ГБ>` (меню принимает только числа от 1) — останавливает ZRAM и удаляет `zram-tools`, пересоздаёт `/swapfile` нужного размера (`fallocate`, запасной вариант `dd`), `mkswap`, `swapon`, запись в fstab.

## Внешние команды и файлы
`/swapfile`

## Откуда вызывается
- [[submenu_memory]]
