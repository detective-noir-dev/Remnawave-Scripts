---
aliases: ["Запись нового описания"]
tags: [rw-func]
тип: действие
строка: 72
файл: lib/firewall.sh
---
# Запись нового описания

`edit_port_description` · `lib/firewall.sh` L72

Через `jq map(if … then .description = … else . end)` обновляет описание записи с заданными `port` + `protocol`.

## Использует (общие хелперы)
`ensure_jq`

## Внешние команды и файлы
`ports.json`, `jq`

## Откуда вызывается
- [[edit_port]]
