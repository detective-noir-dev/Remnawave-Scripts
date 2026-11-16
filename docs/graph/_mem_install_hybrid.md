---
aliases: ["Гибрид ZRAM + Disk Swap"]
tags: [rw-helper]
тип: внутренняя функция
строка: 2859
файл: scripts.sh
---
# Гибрид ZRAM + Disk Swap

`_mem_install_hybrid` · `scripts.sh` L2859

ZRAM 50% (lz4, приоритет 100) плюс резервный `/swapfile` на 2 ГБ с приоритетом −2. Запись в `/etc/fstab`, автозапуск `zramswap`.

## Использует (общие хелперы)
`_pkg_install`

## Внешние команды и файлы
`zram-tools`, `/etc/default/zramswap`, `/swapfile`

## Откуда вызывается
- [[submenu_memory]]
