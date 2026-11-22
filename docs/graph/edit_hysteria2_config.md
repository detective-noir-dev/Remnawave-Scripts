---
aliases: ["Редактирование конфига Hysteria2"]
tags: [rw-func]
тип: действие
строка: 87
файл: lib/hy2.sh
---
# Редактирование конфига Hysteria2

`edit_hysteria2_config` · `lib/hy2.sh` L87

Открывает `/etc/hysteria/config.yaml` в nano/vim/vi. Если файла нет — сначала создаёт базовый.

## Что происходит
1. спрашивает домен (по умолчанию example.com) и порт (по умолчанию 443)
2. генерирует случайный 32-символьный пароль, выводит его пользователю и создаёт конфиг: `listen`, `tls` (cert/key), закомментированный блок `acme`, `auth: password`, `masquerade: proxy`
3. открывает редактор

## Внешние команды и файлы
`/etc/hysteria/config.yaml`

## Откуда вызывается
- [[submenu_hysteria2]]
