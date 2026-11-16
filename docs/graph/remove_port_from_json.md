---
aliases: ["Удаление порта из ports.json"]
tags: [rw-func]
тип: действие
строка: 688
файл: scripts.sh
---
# Удаление порта из ports.json

`remove_port_from_json` · `scripts.sh` L688

Оставляет в массиве все записи, кроме совпадающей по `port` + `protocol` (`jq map(select(...))`).

## Использует (общие хелперы)
`ensure_jq`

## Внешние команды и файлы
`ports.json`, `jq`

## Откуда вызывается
- [[close_port]]
