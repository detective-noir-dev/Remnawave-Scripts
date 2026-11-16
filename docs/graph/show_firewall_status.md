---
aliases: ["Статус файрвола"]
tags: [rw-func]
тип: действие
строка: 1020
файл: scripts.sh
---
# Статус файрвола

`show_firewall_status` · `scripts.sh` L1020

Показывает подробный статус обнаруженного файрвола: `ufw status verbose`, `firewall-cmd --state` + `--list-all` или `iptables -L -n -v --line-numbers`.

## Использует (общие хелперы)
`detect_firewall`

## Внешние команды и файлы
`ufw`, `firewall-cmd`, `iptables`

## Откуда вызывается
- [[port_management]]
