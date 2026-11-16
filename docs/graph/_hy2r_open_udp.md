---
aliases: ["Открыть UDP-порт для Hysteria2"]
tags: [rw-helper]
тип: внутренняя функция
строка: 1723
файл: scripts.sh
---
# Открыть UDP-порт для Hysteria2

`_hy2r_open_udp` · `scripts.sh` L1723

Открывает UDP-порт в ufw/firewalld/iptables и записывает его в `ports.json` с описанием «Hysteria2 (Remnanode)». Возвращает 1, если файрвол не найден.

## Использует (общие хелперы)
`detect_firewall`, `add_port_to_json`

## Откуда вызывается
- [[setup_hysteria2_remnanode]]
