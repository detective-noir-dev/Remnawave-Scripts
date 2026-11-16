---
aliases: ["Память и Swap (подменю)"]
tags: [rw-menu]
тип: меню
строка: 2919
файл: scripts.sh
---
# Память и Swap (подменю)

`submenu_memory` · `scripts.sh` L2919

Показывает RAM и состояние swap, считает рекомендацию по объёму RAM (≤1 ГБ → ZRAM 60% + 2 ГБ, ≤2 ГБ → 50% + 2, ≤4 ГБ → 40% + 4, больше → 25% + 4). Пункты: 1 гибрид, 2 только ZRAM, 3 только Disk Swap, 4 удалить всё, 5 статус, 6 инструкции. 0 — назад.

## Содержит
- [[_mem_swap_status]] — Краткий статус swap
- [[_mem_install_hybrid]] — Гибрид ZRAM + Disk Swap
- [[_mem_install_zram]] — Только ZRAM
- [[_mem_install_swap]] — Только Disk Swap
- [[_mem_remove_all]] — Удалить ZRAM и Swap
- [[_mem_show_status]] — Подробный статус памяти
- [[_mem_show_instructions]] — Инструкция по памяти

## Откуда вызывается
- [[submenu_maintenance]]
