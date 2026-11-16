#!/bin/bash
# Пересобирает SHA256SUMS. Запускать перед коммитом, если менялись scripts.sh, lib/*, lang/*, uninstall.sh, countries.csv или version.txt.
# Проверка тем же скриптом: tools/gen-checksums.sh --check
# Руками запускать не обязательно: .githooks/pre-commit делает это сам (подключение: tools/setup-hooks.sh).
set -euo pipefail
cd "$(dirname "$0")/.."

# новый модуль в lib/ попадает в список сам
FILES=(scripts.sh uninstall.sh countries.csv version.txt lang/ru.sh lang/en.sh)
for f in lib/*.sh; do FILES+=("$f"); done

if [ "${1:-}" = "--check" ]; then
    sha256sum -c --quiet SHA256SUMS
    # новый файл из списка не должен тихо выпасть из SHA256SUMS
    for f in "${FILES[@]}"; do
        grep -q "  $f\$" SHA256SUMS || { echo "SHA256SUMS: нет записи для $f" >&2; exit 1; }
    done
    # и в SHA256SUMS не должно быть записей про удалённые файлы
    if [ "$(wc -l < SHA256SUMS)" -ne "${#FILES[@]}" ]; then
        echo "SHA256SUMS: число записей не совпадает с числом файлов (${#FILES[@]})" >&2
        exit 1
    fi
    echo "SHA256SUMS актуален"
else
    sha256sum --text "${FILES[@]}" > SHA256SUMS
    echo "SHA256SUMS обновлён (${#FILES[@]} файлов)"
fi
