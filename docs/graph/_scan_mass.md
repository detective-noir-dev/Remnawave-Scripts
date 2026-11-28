---
aliases: ["Массовое сканирование"]
tags: [rw-helper]
тип: внутренняя функция
строка: 164
файл: lib/scanner.sh
---
# Массовое сканирование

`_scan_mass` · `lib/scanner.sh` L164

Сканирует все цели из `targets.txt`, прогресс `[N/total]`. Ctrl+C прерывает с сохранением уже найденного. Результат в `reports/mass_<ts>.csv`, затем `_scan_analyze`. Если список пуст — подсказка добавить цели. Использует `_scan_ensure` и `_scan_analyze`.

## Внешние команды и файлы
`/opt/RealityTLScanner/targets.txt`

## Откуда вызывается
- [[submenu_scanner]]
