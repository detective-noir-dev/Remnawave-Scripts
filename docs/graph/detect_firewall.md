---
aliases: ["Определение файрвола"]
tags: [rw-shared]
тип: общий хелпер
строка: 618
файл: scripts.sh
---
# Определение файрвола

`detect_firewall` · `scripts.sh` L618

Печатает `ufw`, `firewalld`, `iptables` или `none` — по первой найденной команде (`ufw` → `firewall-cmd` → `iptables`). Результат разбирают `case`-ы в работе с портами, SSH и Hysteria2.

## Откуда вызывается
- [[Общие хелперы]]
