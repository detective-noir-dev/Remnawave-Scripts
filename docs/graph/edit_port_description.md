---
aliases: ["Запись нового описания"]
tags: [rw-func]
тип: действие
строка: 697
файл: scripts.sh
---
# Запись нового описания

`edit_port_description` · `scripts.sh` L697

Через `jq map(if … then .description = … else . end)` обновляет описание записи с заданными `port` + `protocol`.

## Использует (общие хелперы)
`ensure_jq`

## Внешние команды и файлы
`ports.json`, `jq`

## Откуда вызывается
- [[edit_port]]
