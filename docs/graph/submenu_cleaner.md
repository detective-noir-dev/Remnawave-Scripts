---
aliases: ["Очистка системы (подменю)"]
tags: [rw-menu]
тип: меню
строка: 2737
файл: scripts.sh
---
# Очистка системы (подменю)

`submenu_cleaner` · `scripts.sh` L2737

Показывает свободное место на `/` и пункты: 1 полная уборка, 2 APT, 3 журналы, 4 Docker, 5 /tmp, 6 Snap, 7 анализатор диска. Каждая очистка идёт через `_clean_run`, который считает освобождённое место. 0 — назад.

## Содержит
- [[_clean_run]] — Обёртка очистки с замером
- [[_do_clean_all]] — Полная уборка
- [[_do_clean_apt]] — Очистка APT
- [[_do_clean_journal]] — Очистка журналов
- [[_do_clean_docker]] — Очистка Docker
- [[_do_clean_tmp]] — Очистка /tmp
- [[_do_clean_snap]] — Очистка Snap
- [[_disk_analyzer]] — Анализатор диска

## Откуда вызывается
- [[submenu_maintenance]]
