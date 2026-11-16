---
aliases: ["Страна выхода WARP"]
tags: [rw-helper]
тип: внутренняя функция
строка: 1958
файл: scripts.sh
---
# Страна выхода WARP

`_warp_country` · `scripts.sh` L1958

Через SOCKS5-прокси на порту `$1` запрашивает `cloudflare.com/cdn-cgi/trace` и печатает код страны из строки `loc=XX`. Используется в `install_warp` и `warp_status`.

## Внешние команды и файлы
`cdn-cgi/trace`

## Откуда вызывается
- [[warp_status]]
