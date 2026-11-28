---
aliases: ["Открыть порт"]
tags: [rw-func]
тип: действие
строка: 144
файл: lib/firewall.sh
---
# Открыть порт

`open_port` · `lib/firewall.sh` L144

Открывает порт в файрволе и записывает его в `ports.json` с описанием.

## Что происходит
1. `detect_firewall`; если `none` — ошибка
2. ввод порта 1–65535
3. протокол: 1 TCP / 2 UDP / 3 оба
4. описание (по умолчанию «No description»)
5. передаёт операцию в [[port_apply]]: ufw `allow`, firewalld `--permanent --add-port` + `--reload`, iptables `-I INPUT … ACCEPT` (если такого правила ещё нет) + `netfilter-persistent save`
6. добавляет запись в `ports.json` только после успешного применения правила

## Использует (общие хелперы)
`detect_firewall`

## Внешние команды и файлы
`ufw`, `firewall-cmd`, `iptables`

## Вызывает
- [[port_apply]] — Применение правила без интерактивных запросов

## Откуда вызывается
- [[port_management]]
