---
aliases: ["Определение файрвола"]
tags: [rw-shared]
тип: общий хелпер
строка: 5
файл: lib/firewall.sh
---
# Определение файрвола

`detect_firewall` · `lib/firewall.sh` L5

Печатает `ufw`, `firewalld`, `iptables` или `none` — по первой найденной команде (`ufw` → `firewall-cmd` → `iptables`). Результат разбирают `case`-ы в работе с портами, SSH и Hysteria2.

## Откуда вызывается
- [[Общие хелперы]]
