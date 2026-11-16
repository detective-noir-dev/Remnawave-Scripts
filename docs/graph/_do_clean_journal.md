---
aliases: ["Очистка журналов"]
tags: [rw-helper]
тип: внутренняя функция
строка: 2611
файл: scripts.sh
---
# Очистка журналов

`_do_clean_journal` · `scripts.sh` L2611

`journalctl --vacuum-time=3d` и `--vacuum-size=100M`: оставляет логи за 3 дня и не более 100 МБ.

## Внешние команды и файлы
`journalctl`

## Откуда вызывается
- [[submenu_cleaner]]
