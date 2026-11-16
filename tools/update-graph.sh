#!/bin/bash
# Обновляет в карте Obsidian (docs/graph/*.md и docs/rw-scripts-map.canvas) файл и номер строки каждой функции:
# после правок кода номера плывут, а функции могут переезжать между scripts.sh и lib/*.sh.
# Структуру карты (ссылки между заметками) не трогает. Запуск: bash tools/update-graph.sh
set -euo pipefail
cd "$(dirname "$0")/.."

# имя -> "файл:строка" для каждой определённой функции
declare -A where
while IFS=: read -r file line name; do
    where["$name"]="$file:$line"
done < <(grep -nE '^[A-Za-z_][A-Za-z_0-9]*\(\) *\{' scripts.sh lib/*.sh \
    | sed -E 's/^([^:]+):([0-9]+):([A-Za-z_0-9]+)\(\).*/\1:\2:\3/')

changed=0
for note in docs/graph/*.md; do
    # заголовок вида: `name` · `scripts.sh` L123
    name=$(grep -m1 -oE '^`[A-Za-z_][A-Za-z_0-9]*` · `[^`]+` L[0-9]+' "$note" | sed -E 's/^`([^`]+)`.*/\1/' || true)
    [ -n "$name" ] || continue
    loc="${where[$name]:-}"
    if [ -z "$loc" ]; then echo "нет функции $name (заметка $note)" >&2; continue; fi
    file="${loc%%:*}"; line="${loc##*:}"
    sed -i -E \
        -e "s/^строка: [0-9]+/строка: $line/" \
        -e "s#^файл: .*#файл: $file#" \
        -e "s#^(\`$name\` · \`)[^\`]+(\` L)[0-9]+#\1$file\2$line#" \
        "$note"
    changed=$((changed + 1))
done

# канвас: «`name` L123» и «`name` (L123)»
canvas=docs/rw-scripts-map.canvas
if [ -f "$canvas" ]; then
    for name in "${!where[@]}"; do
        line="${where[$name]##*:}"
        sed -i -E "s/(\`$name\` \(?L)[0-9]+/\1$line/g" "$canvas"
    done
fi

echo "карта обновлена: заметок $changed"
