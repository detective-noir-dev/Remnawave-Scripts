---
aliases: ["Установка RealiTLScanner"]
tags: [rw-helper]
тип: внутренняя функция
строка: 10
файл: lib/scanner.sh
---
# Установка RealiTLScanner

`_scan_install` · `lib/scanner.sh` L10

Собирает сканер из исходников и скачивает GeoIP-базу.

## Что происходит
1. создаёт `/opt/RealityTLScanner/reports` (без прав — через `sudo` и `chown` на текущего пользователя)
2. ставит `git`, `curl`, `wget` (`_pkg_install`)
3. определяет последнюю версию Go (`go.dev/VERSION`, запасная go1.22.6) и архитектуру (amd64/arm64)
4. качает и распаковывает Go в `/usr/local/go`
5. `git clone xtls/RealiTLScanner`, `go build` → `/opt/RealityTLScanner/RealiTLScanner`
6. качает `Country.mmdb` (Loyalsoldier/geoip)

## Использует (общие хелперы)
`_pkg_install`

## Внешние команды и файлы
`go`, `git`, `/opt/RealityTLScanner`

## Откуда вызывается
- [[submenu_scanner]]
