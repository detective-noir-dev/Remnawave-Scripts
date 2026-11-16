---
aliases: ["Только ZRAM"]
tags: [rw-helper]
тип: внутренняя функция
строка: 2878
файл: scripts.sh
---
# Только ZRAM

`_mem_install_zram` · `scripts.sh` L2878

`_mem_install_zram <процент>` — отключает старый swap, удаляет `/swapfile` и его запись в fstab, ставит `zram-tools`, пишет конфиг с заданным процентом, включает сервис `zramswap`.

## Использует (общие хелперы)
`_pkg_install`

## Внешние команды и файлы
`zram-tools`

## Откуда вызывается
- [[submenu_memory]]
