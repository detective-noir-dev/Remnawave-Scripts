---
aliases: ["Запись порта в ports.json"]
tags: [rw-func]
тип: действие
строка: 49
файл: lib/firewall.sh
---
# Запись порта в ports.json

`add_port_to_json` · `lib/firewall.sh` L49

Добавляет в `ports.json` (заменяя запись с тем же портом и протоколом) объект `{port, protocol, description, timestamp}` через `jq --arg` (кавычки в описании безопасны). Запись атомарна: сначала во временный файл, затем `mv`; если `jq` упал — файл остаётся нетронутым.

## Использует (общие хелперы)
`init_ports_file`, `ensure_jq`

## Внешние команды и файлы
`ports.json`, `jq`

## Откуда вызывается
- [[open_port]]
