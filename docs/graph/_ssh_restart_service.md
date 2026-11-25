---
aliases: ["Перезапуск SSH"]
tags: [rw-helper]
тип: хелпер
строка: 136
файл: lib/server.sh
---
# Перезапуск SSH

`_ssh_restart_service` · `lib/server.sh` L136

Перезапускает SSH-службу: сначала `sshd`, затем `ssh` — так поддерживаются разные названия systemd-юнита в дистрибутивах.

## Откуда вызывается
- [[disable_ssh_password_auth]]
