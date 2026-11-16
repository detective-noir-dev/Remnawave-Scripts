#!/bin/bash
# Простые проверки без внешних зависимостей. Запуск: bash tests/run.sh
cd "$(dirname "$0")/.." || exit 1
fail=0
ok()  { echo "ok   - $1"; }
bad() { echo "FAIL - $1"; fail=1; }

# 1. синтаксис
for f in scripts.sh install.sh uninstall.sh lang/*.sh tools/*.sh tests/*.sh; do
    if bash -n "$f" 2>/dev/null; then ok "bash -n $f"; else bad "bash -n $f"; fi
done

# 2. в словарях одинаковые ключи
keys() { grep -oE '^\s+[A-Z0-9_]+\)' "$1" | tr -d ' ()' | sort -u; }
if diff <(keys lang/ru.sh) <(keys lang/en.sh) >/dev/null; then
    ok "lang/ru.sh и lang/en.sh: одинаковые ключи"
else
    bad "ключи lang/ru.sh и lang/en.sh расходятся:"; diff <(keys lang/ru.sh) <(keys lang/en.sh)
fi

# 3. каждый tr_text KEY из кода есть в словаре
missing=$(grep -ohE 'tr_text [A-Z][A-Z0-9_]+' scripts.sh | awk '{print $2}' | sort -u | comm -23 - <(keys lang/en.sh))
if [ -z "$missing" ]; then ok "все tr_text KEY есть в словаре"; else bad "нет в словаре: $(echo $missing)"; fi

# 4. SHA256SUMS соответствует файлам
if bash tools/gen-checksums.sh --check >/dev/null 2>&1; then ok "SHA256SUMS актуален"; else bad "SHA256SUMS устарел: запусти tools/gen-checksums.sh"; fi

# 5. fetch_verified: подходящий хэш ставит файл, чужой хэш и неизвестное имя отклоняются
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
mkdir "$tmp/repo"; echo "hello" > "$tmp/repo/a.txt"
sums="$(sha256sum "$tmp/repo/a.txt" | cut -d' ' -f1)  a.txt"
# shellcheck disable=SC1090
source <(sed -n '/^_sha256_of()/,/^# ====== СЛОВАРЬ/p' scripts.sh | sed '$d')
REPO_URL="file://$(cd "$tmp/repo" && { pwd -W 2>/dev/null || pwd; })"
fetch_verified a.txt "$tmp/out" "$sums"; rc=$?
if [ $rc -eq 0 ] && [ "$(cat "$tmp/out")" = "hello" ]; then ok "fetch_verified: верный хэш"; else bad "fetch_verified: верный хэш (rc=$rc)"; fi
rm -f "$tmp/out"
fetch_verified a.txt "$tmp/out" "$(printf '%064d  a.txt' 0)"; rc=$?
if [ $rc -eq 3 ] && [ ! -e "$tmp/out" ] && [ ! -e "$tmp/out.part" ]; then ok "fetch_verified: чужой хэш отклонён"; else bad "fetch_verified: чужой хэш (rc=$rc)"; fi
fetch_verified b.txt "$tmp/out" "$sums"; rc=$?
if [ $rc -eq 2 ] && [ ! -e "$tmp/out" ]; then ok "fetch_verified: неизвестное имя отклонено"; else bad "fetch_verified: неизвестное имя (rc=$rc)"; fi
fetch_verified a.txt "$tmp/out" ""; rc=$?
if [ $rc -eq 2 ]; then ok "fetch_verified: пустой SHA256SUMS отклонён"; else bad "fetch_verified: пустой SHA256SUMS (rc=$rc)"; fi

exit $fail
