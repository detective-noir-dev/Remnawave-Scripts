---
aliases: ["Редактирование конфига Hysteria2"]
tags: [rw-func]
тип: действие
строка: 1392
файл: scripts.sh
---
# Редактирование конфига Hysteria2

`edit_hysteria2_config` · `scripts.sh` L1392

Открывает `/etc/hysteria/config.yaml` в nano/vim/vi. Если файла нет — сначала создаёт базовый.

## Что происходит
1. спрашивает домен (по умолчанию example.com) и порт (по умолчанию 443)
2. создаёт конфиг: `listen`, `tls` (cert/key), закомментированный блок `acme`, `auth: password`, `masquerade: proxy`
3. открывает редактор

## Внешние команды и файлы
`/etc/hysteria/config.yaml`

## Откуда вызывается
- [[submenu_hysteria2]]
