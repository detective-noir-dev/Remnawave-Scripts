---
aliases: ["Список портов"]
tags: [rw-func]
тип: действие
строка: 275
файл: lib/firewall.sh
---
# Список портов

`list_ports` · `lib/firewall.sh` L275

Рисует таблицу открытых портов: Port / Protocol / Description / Source. Описание длиннее 36 символов обрезается. Источник: `script` (открыт через этот скрипт) или `system` (был открыт до него). В конце сводка «Всего / Через скрипт / Системные».

## Что происходит
1. `init_ports_file`
2. `sync_ports_with_firewall` — подтянуть порты из файрвола
3. вывод таблицы через `jq` + `printf`
4. подсчёт итогов

## Использует (общие хелперы)
`ensure_jq`, `init_ports_file`

## Вызывает
- [[sync_ports_with_firewall]] — Синхронизация ports.json с файрволом

## Откуда вызывается
- [[port_management]]
