---
aliases: ["Удаление порта из ports.json"]
tags: [rw-func]
тип: действие
строка: 62
файл: lib/firewall.sh
---
# Удаление порта из ports.json

`remove_port_from_json` · `lib/firewall.sh` L62

Оставляет в массиве все записи, кроме совпадающей по `port` + `protocol` (`jq map(select(...))`).

## Использует (общие хелперы)
`ensure_jq`

## Внешние команды и файлы
`ports.json`, `jq`

## Откуда вызывается
- [[close_port]]
