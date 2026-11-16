---
aliases: ["Меню 4 · Maintenance"]
tags: [rw-menu]
тип: меню
строка: 2385
файл: scripts.sh
---
# Меню 4 · Maintenance

`submenu_maintenance` · `scripts.sh` L2385

Подменю обслуживания: 1 обновить скрипт, 2 обновить пакеты, 3 очистка, 4 память/swap, 5 сканер Reality, 6 удалить скрипт. 0 — назад.

## Содержит
- [[check_update]] — Обновление скрипта
- [[apt_update_upgrade]] — Обновление системных пакетов
- [[submenu_cleaner]] — Очистка системы (подменю)
- [[submenu_memory]] — Память и Swap (подменю)
- [[submenu_scanner]] — Reality TLS Scanner (подменю)
- [[delete_self]] — Удаление скрипта

## Откуда вызывается
- [[show_main_menu]]
