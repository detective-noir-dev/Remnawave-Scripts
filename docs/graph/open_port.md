---
aliases: ["Открыть порт"]
tags: [rw-func]
тип: действие
строка: 151
файл: lib/firewall.sh
---
# Открыть порт

`open_port` · `lib/firewall.sh` L151

Открывает порт в файрволе и записывает его в `ports.json` с описанием.

## Что происходит
1. `detect_firewall`; если `none` — ошибка
2. ввод порта 1–65535
3. протокол: 1 TCP / 2 UDP / 3 оба
4. описание (по умолчанию «No description»)
5. ufw: `allow`; firewalld: `--permanent --add-port` + `--reload`; iptables: `-A INPUT … ACCEPT` + `netfilter-persistent save`
6. `add_port_to_json` для каждого протокола

## Использует (общие хелперы)
`detect_firewall`

## Внешние команды и файлы
`ufw`, `firewall-cmd`, `iptables`

## Вызывает
- [[add_port_to_json]] — Запись порта в ports.json

## Откуда вызывается
- [[port_management]]
