---
aliases: ["Обновление системных пакетов"]
tags: [rw-func]
тип: действие
строка: 225
файл: lib/maintenance.sh
---
# Обновление системных пакетов

`apt_update_upgrade` · `lib/maintenance.sh` L225

`apt update` и затем `apt upgrade -y` под спиннером, вывод скрыт. Каждый шаг проверяется отдельно. Перед стартом — подтверждение.

## Использует (общие хелперы)
`loading_bar`

## Внешние команды и файлы
`apt / apt-get`

## Откуда вызывается
- [[submenu_maintenance]]
