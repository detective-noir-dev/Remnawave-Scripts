---
aliases: ["Анализатор диска"]
tags: [rw-menu]
тип: меню
строка: 2711
файл: scripts.sh
---
# Анализатор диска

`_disk_analyzer` · `scripts.sh` L2711

Подменю выбора каталога для просмотра: `/var/log` (можно очищать), `/var/lib/docker` (только просмотр), `/var/cache/apt` (удаление), `/tmp` (удаление), `/opt/remnawave` (только просмотр). Каждый открывает `_disk_inspector` со своим режимом.

## Содержит
- [[_disk_inspector]] — Инспектор каталога

## Откуда вызывается
- [[submenu_cleaner]]
