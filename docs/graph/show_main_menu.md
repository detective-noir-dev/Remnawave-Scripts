---
aliases: ["Главное меню"]
tags: [rw-root]
тип: главное меню
строка: 185
файл: lib/menus.sh
---
# Главное меню

`show_main_menu` · `lib/menus.sh` L185

Точка входа. Бесконечный цикл: перерисовывает дашборд, один раз за сессию тихо проверяет обновления, печатает 6 групп с подсказками и по `case` передаёт управление в подменю. Пункт 0 завершает скрипт (`exit 0`). Вызывается последней строкой файла (`# ЗАПУСК`).

## Что происходит
1. `show_dashboard` — шапка с системной информацией
2. при первом проходе (`_UPDATE_CHECKED=0`) — `auto_check_update`
3. вывод пунктов 1–6 и 0
4. `read` выбора → `submenu_*`

## Содержит
- [[show_dashboard]] — Системный дашборд
- [[auto_check_update]] — Тихая проверка обновлений
- [[submenu_id_flags]] — Меню 1 · Short ID & Flags
- [[submenu_monitor]] — Меню 2 · Resource Monitor
- [[submenu_network]] — Меню 3 · Network & Ports
- [[submenu_maintenance]] — Меню 4 · Maintenance
- [[submenu_server]] — Меню 5 · Server Setup
- [[submenu_thirdparty]] — Меню 6 · Сторонние скрипты
- [[Общие хелперы]] — Общие функции, которые вызываются из многих мест
- [[Окружение]] — Файлы и каталоги вокруг скрипта
