---
aliases: ["Статус файрвола"]
tags: [rw-func]
тип: действие
строка: 320
файл: lib/firewall.sh
---
# Статус файрвола

`show_firewall_status` · `lib/firewall.sh` L320

Показывает подробный статус обнаруженного файрвола: `ufw status verbose`, `firewall-cmd --state` + `--list-all` или `iptables -L -n -v --line-numbers`.

## Использует (общие хелперы)
`detect_firewall`

## Внешние команды и файлы
`ufw`, `firewall-cmd`, `iptables`

## Откуда вызывается
- [[port_management]]
