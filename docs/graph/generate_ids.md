---
aliases: ["Генерация Short ID"]
tags: [rw-func]
тип: действие
строка: 1106
файл: scripts.sh
---
# Генерация Short ID

`generate_ids` · `scripts.sh` L1106

Генерирует N случайных 16-символьных hex-идентификаторов (для `shortIds` в Reality/Xray), по одному в строке в формате `"id",` — готово для вставки в JSON.

## Что происходит
1. `ensure_xxd`
2. спрашивает количество (должно быть числом > 0)
3. для каждого: `head -c 8 /dev/urandom | xxd -p`

## Внешние команды и файлы
`/dev/urandom`, `xxd`

## Вызывает
- [[ensure_xxd]] — Установка xxd

## Откуда вызывается
- [[submenu_id_flags]]
