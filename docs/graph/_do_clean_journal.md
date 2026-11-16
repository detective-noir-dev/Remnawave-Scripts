---
aliases: ["Очистка журналов"]
tags: [rw-helper]
тип: внутренняя функция
строка: 44
файл: lib/cleaner.sh
---
# Очистка журналов

`_do_clean_journal` · `lib/cleaner.sh` L44

`journalctl --vacuum-time=3d` и `--vacuum-size=100M`: оставляет логи за 3 дня и не более 100 МБ.

## Внешние команды и файлы
`journalctl`

## Откуда вызывается
- [[submenu_cleaner]]
