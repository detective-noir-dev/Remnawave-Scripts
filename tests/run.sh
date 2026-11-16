#!/bin/bash
# Простые проверки без внешних зависимостей. Запуск: bash tests/run.sh
cd "$(dirname "$0")/.." || exit 1
fail=0
ok()  { echo "ok   - $1"; }
bad() { echo "FAIL - $1"; fail=1; }

# 1. синтаксис
for f in scripts.sh install.sh uninstall.sh lib/*.sh lang/*.sh tools/*.sh tests/*.sh .githooks/*; do
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
missing=$(grep -ohE 'tr_text [A-Z][A-Z0-9_]+' scripts.sh lib/*.sh | awk '{print $2}' | sort -u | comm -23 - <(keys lang/en.sh))
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

# 6. каждая функция определена ровно один раз во всём коде (при нарезке на модули легко задвоить)
dups=$(grep -hoE '^[A-Za-z_][A-Za-z_0-9]*\(\) *\{' scripts.sh lib/*.sh | sed 's/().*//' | sort | uniq -d)
if [ -z "$dups" ]; then ok "функции не дублируются между scripts.sh и lib/*.sh"; else bad "повторные определения: $(echo $dups)"; fi

# 7. в модулях только определения: ничего не выполняется при подключении
for f in lib/*.sh; do
    bad_lines=$(awk '/^[A-Za-z_0-9]+\(\) *\{/ {infn=1} !infn && !/^#/ && !/^[[:space:]]*$/ && !/^[A-Z_][A-Z_0-9]*=/ {print FILENAME": "NR": "$0} /^\}/ {infn=0}' "$f")
    if [ -z "$bad_lines" ]; then ok "$f: только функции и переменные"; else bad "$f: код вне функций:"; echo "$bad_lines"; fi
done

# 8. 'sudo' вызывается только через $SUDO (в root-окружении sudo может не быть)
raw=$(grep -nE '(^|[[:space:]|&;(])sudo ' lib/*.sh scripts.sh | grep -vE '(echo|printf) .*sudo |command -v sudo' | grep -vE '^[^:]+:[0-9]+:[[:space:]]*#')
if [ -z "$raw" ]; then ok "нет прямых вызовов sudo"; else bad 'прямой sudo (используйте $SUDO):'; echo "$raw"; fi

# 9. rw-scripts doctor и version работают из клона репозитория (HOME пустой: установленная копия не мешает)
mkdir -p "$tmp/home"
if out=$(HOME="$tmp/home" XDG_DATA_HOME="" bash scripts.sh doctor 2>&1); then ok "rw-scripts doctor"; else bad "rw-scripts doctor"; echo "$out" | tail -15; fi
if [ "$(HOME="$tmp/home" XDG_DATA_HOME="" bash scripts.sh version 2>/dev/null)" = "dev" ]; then ok "rw-scripts version"; else bad "rw-scripts version"; fi

# 11. модули докачиваются с проверкой хэша, если установлен только scripts.sh (обновление со старой версии)
mkdir -p "$tmp/mrepo/lib"
echo 'mod_pkg_loaded() { :; }' > "$tmp/mrepo/lib/pkg.sh"
echo 'mod_x_loaded() { :; }'   > "$tmp/mrepo/lib/x.sh"
msums=$(cd "$tmp/mrepo" && sha256sum lib/pkg.sh lib/x.sh)
(
    # shellcheck disable=SC1090
    source <(sed -n '/^_sha256_of()/,/^# ====== СЛОВАРЬ/p' scripts.sh | sed '$d')
    # shellcheck disable=SC1090
    source <(sed -n '/^_lib_names()/,/^load_modules || exit 1/p' scripts.sh | sed '$d')
    DATA_DIR="$tmp/mdata"; LIB_DIR="$DATA_DIR/lib"
    REPO_URL="file://$(cd "$tmp/mrepo" && { pwd -W 2>/dev/null || pwd; })"
    # curl с file:// отдаёт SHA256SUMS из подготовленного каталога
    echo "$msums" > "$tmp/mrepo/SHA256SUMS"
    load_modules
    declare -F mod_pkg_loaded >/dev/null && declare -F mod_x_loaded >/dev/null
); rc=$?
if [ $rc -eq 0 ]; then ok "load_modules: модули докачаны и подключены"; else bad "load_modules: самовосстановление (rc=$rc)"; fi
# подменённый модуль не должен подключаться
echo 'echo EVIL' > "$tmp/mrepo/lib/x.sh"
(
    # shellcheck disable=SC1090
    source <(sed -n '/^_sha256_of()/,/^# ====== СЛОВАРЬ/p' scripts.sh | sed '$d')
    # shellcheck disable=SC1090
    source <(sed -n '/^_lib_names()/,/^load_modules || exit 1/p' scripts.sh | sed '$d')
    DATA_DIR="$tmp/mdata2"; LIB_DIR="$DATA_DIR/lib"
    REPO_URL="file://$(cd "$tmp/mrepo" && { pwd -W 2>/dev/null || pwd; })"
    load_modules 2>/dev/null
); rc=$?
if [ $rc -ne 0 ] && [ ! -e "$tmp/mdata2/lib" ]; then ok "load_modules: чужой хэш отклонён, lib не создан"; else bad "load_modules: подмену не отклонил (rc=$rc)"; fi

# 12. verify и rollback на копии «установленной» раскладки
(
    H="$tmp/inst"; D="$H/.local/share/remnawave"; B="$H/.local/bin/rw-scripts"
    export HOME="$H"; unset XDG_DATA_HOME
    mkdir -p "$H/.local/bin" "$D"
    layout() {
        cp scripts.sh "$B"; chmod +x "$B"
        rm -rf "$D/lib" "$D/lang"; cp -r lib lang "$D/"
        cp version.txt countries.csv uninstall.sh SHA256SUMS "$D/"
    }
    chk() { [ "$2" = "$3" ] || { echo "  $1: получено [$2], ожидалось [$3]"; exit 1; }; }
    layout
    "$B" verify >/dev/null; chk "verify чистая установка" "$?" 0
    echo "# tamper" >> "$D/lib/pkg.sh"
    "$B" verify 2>&1 | grep -q 'lib/pkg.sh'; chk "verify называет изменённый файл" "$?" 0
    "$B" verify >/dev/null; chk "verify: файл изменён" "$?" 1
    layout; rm "$D/SHA256SUMS"
    "$B" verify >/dev/null; chk "verify без SHA256SUMS" "$?" 2
    cp SHA256SUMS "$D/"
    "$B" rollback --yes >/dev/null; chk "rollback без копии" "$?" 1
    mkdir -p "$D/previous"
    cp "$B" "$D/previous/scripts.sh"; cp -r "$D/lib" "$D/previous/lib"; cp -r "$D/lang" "$D/previous/lang"
    printf '1.0.0' > "$D/previous/version.txt"
    "$B" rollback --yes >/dev/null; chk "rollback" "$?" 0
    chk "версия после отката" "$("$B" version)" "1.0.0"
    "$B" rollback --yes >/dev/null; chk "откат отката" "$?" 0
    chk "версия возвращена" "$("$B" version)" "$(cat version.txt)"
    echo x >> "$D/previous/lib/pkg.sh"; cp SHA256SUMS "$D/previous/SHA256SUMS"
    "$B" rollback --yes >/dev/null; chk "повреждённая копия отклонена" "$?" 1
); rc=$?
if [ $rc -eq 0 ]; then ok "verify и rollback"; else bad "verify и rollback"; fi

# 10. юнит-тесты на bats (если установлен)
if command -v bats >/dev/null 2>&1; then
    if bats tests/bats; then ok "bats tests/bats"; else bad "bats tests/bats"; fi
else
    echo "skip - bats не установлен (apt install bats / apk add bats)"
fi

exit $fail
