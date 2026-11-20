---
aliases: ["Меню 4 · Maintenance"]
tags: [rw-menu]
тип: меню
строка: 36
файл: lib/menus.sh
---
# Меню 4 · Maintenance

`submenu_maintenance` · `lib/menus.sh` L36

Подменю обслуживания: 1 обновить скрипт, 2 обновить пакеты, 3 очистка, 4 память/swap, 5 сканер Reality, 6 откат, 7 проверка целостности, 8 удалить скрипт. 0 — назад.

Пункты 3–5 (Cleaner, Memory, Scanner) имеют серые подсказки (`HINT_CLEANER`, `HINT_MEMORY`, `HINT_SCANNER`) под строкой пункта.

## Содержит
- [[check_update]] — Обновление скрипта
- [[apt_update_upgrade]] — Обновление системных пакетов
- [[submenu_cleaner]] — Очистка системы (подменю)
- [[submenu_memory]] — Память и Swap (подменю)
- [[submenu_scanner]] — Reality TLS Scanner (подменю)
- [[delete_self]] — Удаление скрипта

## Откуда вызывается
- [[show_main_menu]]
