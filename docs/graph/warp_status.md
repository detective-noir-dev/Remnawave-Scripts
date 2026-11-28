---
aliases: ["Статус WARP"]
tags: [rw-func]
тип: действие
строка: 136
файл: lib/warp.sh
---
# Статус WARP

`warp_status` · `lib/warp.sh` L136

Если подключён — показывает порт прокси (из `warp-cli settings list`), внешний IP и страну. Иначе — красный статус и вывод `warp-cli status`.

## Вызывает
- [[_warp_country]] — Страна выхода WARP

## Откуда вызывается
- [[submenu_warp]]
