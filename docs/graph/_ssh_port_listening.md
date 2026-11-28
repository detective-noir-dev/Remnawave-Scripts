---
aliases: ["Проверка порта SSH"]
tags: [rw-helper]
тип: хелпер
строка: 163
файл: lib/server.sh
---
# Проверка порта SSH

`_ssh_port_listening` · `lib/server.sh` L163

`_ssh_port_listening <порт>` — до 5 секунд ждёт, пока порт начнут слушать. Без `ss` проверить нечем, возвращает 0.

## Внешние команды и файлы
`ss`

## Откуда вызывается
- [[change_ssh_port]]
