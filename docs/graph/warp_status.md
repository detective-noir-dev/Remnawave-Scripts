---
aliases: ["Статус WARP"]
tags: [rw-func]
тип: действие
строка: 2050
файл: scripts.sh
---
# Статус WARP

`warp_status` · `scripts.sh` L2050

Если подключён — показывает порт прокси (из `warp-cli settings list`), внешний IP и страну. Иначе — красный статус и вывод `warp-cli status`.

## Вызывает
- [[_warp_country]] — Страна выхода WARP

## Откуда вызывается
- [[submenu_warp]]
