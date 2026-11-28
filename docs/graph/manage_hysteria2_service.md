---
aliases: ["Управление сервисом Hysteria2"]
tags: [rw-menu]
тип: меню
строка: 170
файл: lib/hy2.sh
---
# Управление сервисом Hysteria2

`manage_hysteria2_service` · `lib/hy2.sh` L170

Подменю над `hysteria-server.service`: 1 включить автозапуск и запустить, 2 перезапустить, 3 статус, 4 остановить. 0 — назад. Сообщение об успехе выводится только при успешной команде `systemctl`.

## Внешние команды и файлы
`systemctl`

## Откуда вызывается
- [[submenu_hysteria2]]
