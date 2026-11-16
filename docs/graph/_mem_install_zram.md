---
aliases: ["Только ZRAM"]
tags: [rw-helper]
тип: внутренняя функция
строка: 110
файл: lib/memory.sh
---
# Только ZRAM

`_mem_install_zram` · `lib/memory.sh` L110

`_mem_install_zram <процент>` — отключает старый swap, удаляет `/swapfile` и его запись в fstab, ставит `zram-tools`, пишет конфиг с заданным процентом, включает сервис `zramswap`.

## Использует (общие хелперы)
`_pkg_install`

## Внешние команды и файлы
`zram-tools`

## Откуда вызывается
- [[submenu_memory]]
