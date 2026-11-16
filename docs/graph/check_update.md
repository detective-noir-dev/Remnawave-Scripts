---
aliases: ["Обновление скрипта"]
tags: [rw-func]
тип: действие
строка: 1172
файл: scripts.sh
---
# Обновление скрипта

`check_update` · `scripts.sh` L1172

Сверяет локальную версию с `version.txt` в репозитории и, с подтверждением, обновляет сам скрипт.

## Что происходит
1. скачать `version.txt`, показать текущую и последнюю версии
2. если совпадают — «обновлений нет»
3. спросить (y/n)
4. под спиннером скачать `SHA256SUMS`, затем `scripts.sh`, `lang/ru.sh`, `lang/en.sh`, `version.txt` в staging `$DATA_DIR/.update.PID` (`fetch_verified` сверяет каждый файл)
5. при любом несовпадении хэша — отмена, staging удаляется, ничего не заменено
6. при успехе: словари и `version.txt` на место, `scripts.sh` — последним, `chmod +x`
7. `exec $SCRIPT_PATH` — перезапуск на новой версии

## Использует (общие хелперы)
`loading_bar`, `fetch_verified`

## Внешние команды и файлы
`curl`, `sha256sum`, `REPO_URL`, `SHA256SUMS`

## Откуда вызывается
- [[submenu_maintenance]]
