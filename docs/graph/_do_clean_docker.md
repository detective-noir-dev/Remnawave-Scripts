---
aliases: ["Очистка Docker"]
tags: [rw-helper]
тип: внутренняя функция
строка: 2617
файл: scripts.sh
---
# Очистка Docker

`_do_clean_docker` · `scripts.sh` L2617

`docker system prune -a --volumes -f` — удаляет неиспользуемые образы, контейнеры и тома. Если Docker не установлен — сообщение и выход.

## Внешние команды и файлы
`docker`

## Откуда вызывается
- [[submenu_cleaner]]
