---
aliases: ["Синхронизация ports.json с файрволом"]
tags: [rw-func]
тип: действие
строка: 128
файл: lib/firewall.sh
---
# Синхронизация ports.json с файрволом

`sync_ports_with_firewall` · `lib/firewall.sh` L128

Порты, открытые в файрволе, но отсутствующие в `ports.json`, добавляются с описанием «[System] Opened before script» и `source: system`. Так в списке видно и порты, открытые не через скрипт.

## Использует (общие хелперы)
`ensure_jq`, `init_ports_file`

## Внешние команды и файлы
`ports.json`

## Вызывает
- [[get_firewall_ports]] — Чтение портов из файрвола

## Откуда вызывается
- [[list_ports]]
