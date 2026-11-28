---
aliases: ["Обновление системных пакетов"]
tags: [rw-func]
тип: действие
строка: 141
файл: lib/maintenance.sh
---
# Обновление системных пакетов

`apt_update_upgrade` · `lib/maintenance.sh` L141

`apt update` и затем `apt-get upgrade -y --with-new-pkgs` под спиннером, вывод скрыт; диалоги debconf/dpkg отключены (изменённые конфиги сохраняются). Каждый шаг проверяется отдельно. Перед стартом — подтверждение.

## Использует (общие хелперы)
`loading_bar`

## Внешние команды и файлы
`apt / apt-get`

## Откуда вызывается
- [[submenu_maintenance]]
