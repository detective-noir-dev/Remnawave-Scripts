---
aliases: ["Перезапуск SSH"]
tags: [rw-helper]
тип: хелпер
строка: 154
файл: lib/server.sh
---
# Перезапуск SSH

`_ssh_restart_service` · `lib/server.sh` L154

Перезапускает SSH-службу: сначала `sshd`, затем `ssh` — так поддерживаются разные названия systemd-юнита в дистрибутивах. Если активен `ssh.socket` (socket activation), сначала делает `daemon-reload` и перезапускает сокет.

## Откуда вызывается
- [[disable_ssh_password_auth]]
- [[change_ssh_port]]
- [[show_ssh_config]]
