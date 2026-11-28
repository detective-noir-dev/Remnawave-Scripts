---
aliases: ["Чтение портов из файрвола"]
tags: [rw-func]
тип: действие
строка: 83
файл: lib/firewall.sh
---
# Чтение портов из файрвола

`get_firewall_ports` · `lib/firewall.sh` L83

Возвращает список строк `порт|протокол` из реального файрвола (в ufw учитываются только входящие `ALLOW`/`LIMIT`; в iptables протокол берётся из `tcp dpt:`/`udp dpt:`): парсит `ufw status`, `firewall-cmd --list-ports` или правила `iptables -L INPUT`. Дубликаты убираются (`sort -u`).

## Использует (общие хелперы)
`detect_firewall`

## Внешние команды и файлы
`ufw`, `firewall-cmd`, `iptables`

## Откуда вызывается
- [[sync_ports_with_firewall]]
