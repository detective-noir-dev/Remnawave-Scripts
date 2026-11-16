---
aliases: ["Чтение портов из файрвола"]
tags: [rw-func]
тип: действие
строка: 708
файл: scripts.sh
---
# Чтение портов из файрвола

`get_firewall_ports` · `scripts.sh` L708

Возвращает список строк `порт|протокол` из реального файрвола (два прохода по ufw склеиваются через перевод строки): парсит `ufw status`, `firewall-cmd --list-ports` или правила `iptables -L INPUT`. Дубликаты убираются (`sort -u`).

## Использует (общие хелперы)
`detect_firewall`

## Внешние команды и файлы
`ufw`, `firewall-cmd`, `iptables`

## Откуда вызывается
- [[sync_ports_with_firewall]]
