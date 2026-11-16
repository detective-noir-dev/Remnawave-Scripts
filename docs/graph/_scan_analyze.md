---
aliases: ["Анализ отчёта (ТОП-10 SNI)"]
tags: [rw-helper]
тип: внутренняя функция
строка: 3037
файл: scripts.sh
---
# Анализ отчёта (ТОП-10 SNI)

`_scan_analyze` · `scripts.sh` L3037

Читает CSV-отчёт и выводит ТОП-10 лучших SNI. Вес по издателю сертификата: Google/Apple/Microsoft = 1 (💎), DigiCert/GlobalSign/Sectigo = 2, Cloudflare = 3, Let's Encrypt/ZeroSSL = 4. Остальные отбрасываются. Для каждого — IP, порт, гео, издатель. Используется в `_scan_single`, `_scan_mass` и `_scan_reports`.

## Откуда вызывается
- [[_scan_single]]
