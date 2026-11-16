#!/bin/bash
# Пересобирает SHA256SUMS. Запускать перед коммитом, если менялись scripts.sh, lang/*, uninstall.sh, countries.csv или version.txt.
# Проверка тем же скриптом: tools/gen-checksums.sh --check
set -euo pipefail
cd "$(dirname "$0")/.."

FILES=(scripts.sh uninstall.sh countries.csv version.txt lang/ru.sh lang/en.sh)

if [ "${1:-}" = "--check" ]; then
    sha256sum -c --quiet SHA256SUMS
    # новый файл из списка не должен тихо выпасть из SHA256SUMS
    for f in "${FILES[@]}"; do
        grep -q "  $f\$" SHA256SUMS || { echo "SHA256SUMS: нет записи для $f" >&2; exit 1; }
    done
    echo "SHA256SUMS актуален"
else
    sha256sum --text "${FILES[@]}" > SHA256SUMS
    echo "SHA256SUMS обновлён (${#FILES[@]} файлов)"
fi
