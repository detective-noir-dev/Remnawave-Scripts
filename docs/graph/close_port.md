---
aliases: ["Закрыть порт"]
tags: [rw-func]
тип: действие
строка: 192
файл: lib/firewall.sh
---
# Закрыть порт

`close_port` · `lib/firewall.sh` L192

Закрывает порт в файрволе и убирает его из `ports.json`.

## Что происходит
1. `sync_ports_with_firewall` + `list_ports` — показать актуальный список
2. ввод порта и протокола (TCP/UDP/оба)
3. передаёт операцию в [[port_apply]]: ufw `delete allow`, firewalld `--remove-port` + `--reload`, iptables `-D INPUT`
4. убирает запись из `ports.json` только после успешного удаления правила

## Использует (общие хелперы)
`detect_firewall`

## Внешние команды и файлы
`ufw`, `firewall-cmd`, `iptables`

## Вызывает
- [[port_apply]] — Применение правила без интерактивных запросов

## Откуда вызывается
- [[port_management]]
