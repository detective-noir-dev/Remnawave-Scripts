---
aliases: ["Установка Cloudflare WARP"]
tags: [rw-func]
тип: действие
строка: 1964
файл: scripts.sh
---
# Установка Cloudflare WARP

`install_warp` · `scripts.sh` L1964

Ставит `cloudflare-warp` и настраивает его как локальный SOCKS5-прокси. Только Ubuntu/Debian и только root. Каждый шаг идёт под спиннером.

## Что происходит
1. проверка root и ОС (`/etc/os-release` читается в подоболочке, чтобы не затереть глобальный `VERSION`)
2. ввод порта прокси (по умолчанию 40000)
3. `_warp_prepare_repo` — apt-репозиторий и ключ Cloudflare
4. `apt-get install cloudflare-warp`
5. `_warp_configure <порт>` — регистрация, `proxy port`, `mode proxy`
6. `_warp_connect_wait` — подключение
7. через прокси узнаёт IP (`ifconfig.me`) и страну (`_warp_country`)
8. печатает порт, IP, страну и команды `warp-cli`

## Использует (общие хелперы)
`_run_spinner`

## Внешние команды и файлы
`warp-cli`, `apt-get`

## Вызывает
- [[_warp_prepare_repo]] — Подготовка репозитория WARP
- [[_warp_configure]] — Настройка WARP
- [[_warp_connect_wait]] — Подключение WARP

## Откуда вызывается
- [[submenu_warp]]
