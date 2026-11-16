---
aliases: ["Закрыть порт"]
tags: [rw-func]
тип: действие
строка: 859
файл: scripts.sh
---
# Закрыть порт

`close_port` · `scripts.sh` L859

Закрывает порт в файрволе и убирает его из `ports.json`.

## Что происходит
1. `sync_ports_with_firewall` + `list_ports` — показать актуальный список
2. ввод порта и протокола (TCP/UDP/оба)
3. ufw: `delete allow`; firewalld: `--remove-port` + `--reload`; iptables: `-D INPUT`
4. `remove_port_from_json`

## Использует (общие хелперы)
`detect_firewall`

## Внешние команды и файлы
`ufw`, `firewall-cmd`, `iptables`

## Вызывает
- [[remove_port_from_json]] — Удаление порта из ports.json

## Откуда вызывается
- [[port_management]]
