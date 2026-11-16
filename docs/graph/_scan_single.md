---
aliases: ["Скан одного адреса"]
tags: [rw-helper]
тип: внутренняя функция
строка: 95
файл: lib/scanner.sh
---
# Скан одного адреса

`_scan_single` · `lib/scanner.sh` L95

Проверяет конкретный IP или домен на пригодность для Reality: подходит ли он для маскировки.

## Что происходит
1. `_scan_ensure`
2. ввод цели и портов (через запятую, по умолчанию 443); IP превращается в `/32`
3. для каждого порта запускает `RealiTLScanner -addr … -port … -v`
4. разбирает строки лога: `feasible`, `ip`, `tls`, `alpn`, `cert-domain`, `cert-issuer`, `geo`
5. пишет строку в `reports/scan_<ts>.csv`
6. в конце `_scan_analyze`

## Вызывает
- [[_scan_ensure]] — Проверка наличия сканера
- [[_scan_analyze]] — Анализ отчёта (ТОП-10 SNI)

## Откуда вызывается
- [[submenu_scanner]]
