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

# 4. версия в обоих README (бейдж вверху и строка внизу) совпадает с version.txt
ver=$(tr -d '\r\n' < version.txt)
# readme_versions ФАЙЛ СЛОВО_В_БЕЙДЖЕ ПОДПИСЬ — версии из бейджа и из нижней строки, через пробел
readme_versions() {
    { grep -oE "badge/$2-[0-9]+\.[0-9]+\.[0-9]+" "$1" | sed 's/.*-//'
      grep -oE "^\*\*$3:\*\* [0-9]+\.[0-9]+\.[0-9]+" "$1" | sed 's/.* //'; } | tr '\n' ' '
}
for spec in "README.md версия Версия" "README-ENG.md version Version"; do
    read -r file badge label <<<"$spec"
    found=$(readme_versions "$file" "$badge" "$label")
    if [ "$found" = "$ver $ver " ]; then
        ok "$file: версия $ver"
    else
        bad "$file: ожидалась версия $ver в бейдже и в строке «$label», найдено: ${found:-ничего}"
    fi
done

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

# 6. каждая функция определена ровно один раз во всём коде (при нарезке на модули легко задвоить)
# strip_heredocs ФАЙЛ — текст файла без тел here-документов (в них бывают чужие скрипты, например автодополнение)
strip_heredocs() {
    awk '
        inh { if ($0 == tag) inh = 0; next }
        match($0, /<<-?[[:space:]]*\047?[A-Za-z_]+\047?/) && $0 !~ /<<</ {
            t = substr($0, RSTART, RLENGTH); gsub(/<<-?[[:space:]]*|\047/, "", t); tag = t; inh = 1
        }
        { print }
    ' "$1"
}
dups=$(for f in scripts.sh lib/*.sh; do strip_heredocs "$f"; done | grep -oE '^[A-Za-z_][A-Za-z_0-9]*\(\) *\{' | sed 's/().*//' | sort | uniq -d)
if [ -z "$dups" ]; then ok "функции не дублируются между scripts.sh и lib/*.sh"; else bad "повторные определения: $(echo $dups)"; fi

# 7. в модулях только определения: ничего не выполняется при подключении
for f in lib/*.sh; do
    bad_lines=$(strip_heredocs "$f" | awk -v F="$f" '/^[A-Za-z_0-9]+\(\) *\{/ {infn=1} !infn && !/^#/ && !/^[[:space:]]*$/ && !/^[A-Z_][A-Z_0-9]*=/ {print F": "NR": "$0} /^\}/ {infn=0}')
    if [ -z "$bad_lines" ]; then ok "$f: только функции и переменные"; else bad "$f: код вне функций:"; echo "$bad_lines"; fi
done

# 8. 'sudo' вызывается только через $SUDO (в root-окружении sudo может не быть)
raw=$(grep -nE '(^|[[:space:]|&;(])sudo ' lib/*.sh scripts.sh | grep -vE '(echo|printf) .*sudo |command -v sudo' | grep -vE '^[^:]+:[0-9]+:[[:space:]]*#')
if [ -z "$raw" ]; then ok "нет прямых вызовов sudo"; else bad 'прямой sudo (используйте $SUDO):'; echo "$raw"; fi

# 9. rw-scripts doctor и version работают из клона репозитория (HOME пустой: установленная копия не мешает)
mkdir -p "$tmp/home"
if out=$(HOME="$tmp/home" XDG_DATA_HOME="" bash scripts.sh doctor 2>&1); then ok "rw-scripts doctor"; else bad "rw-scripts doctor"; echo "$out" | tail -15; fi
if [ "$(HOME="$tmp/home" XDG_DATA_HOME="" bash scripts.sh version 2>/dev/null)" = "dev" ]; then ok "rw-scripts version"; else bad "rw-scripts version"; fi

# 10. rollback на копии «установленной» раскладки
(
    H="$tmp/inst"; D="$H/.local/share/remnawave"; B="$H/.local/bin/rw-scripts"
    export HOME="$H"; unset XDG_DATA_HOME
    mkdir -p "$H/.local/bin" "$D"
    layout() {
        cp scripts.sh "$B"; chmod +x "$B"
        rm -rf "${D:?}/lib" "${D:?}/lang"; cp -r lib lang "$D/"
        cp version.txt countries.csv uninstall.sh "$D/"
    }
    chk() { [ "$2" = "$3" ] || { echo "  $1: получено [$2], ожидалось [$3]"; exit 1; }; }
    layout
    "$B" rollback --yes >/dev/null; chk "rollback без копии" "$?" 1
    mkdir -p "$D/previous"
    cp "$B" "$D/previous/scripts.sh"; cp -r "$D/lib" "$D/previous/lib"; cp -r "$D/lang" "$D/previous/lang"
    printf '1.0.0' > "$D/previous/version.txt"
    "$B" rollback --yes >/dev/null; chk "rollback" "$?" 0
    chk "версия после отката" "$("$B" version)" "1.0.0"
    "$B" rollback --yes >/dev/null; chk "откат отката" "$?" 0
    chk "версия возвращена" "$("$B" version)" "$(cat version.txt)"
); rc=$?
if [ $rc -eq 0 ]; then ok "rollback"; else bad "rollback"; fi

# 13. весь видимый текст живёт в lang/: кириллица в коде допустима только в комментариях,
#     в ответах [YyДд] и в названии языка "Русский" (grep -P нет в busybox, поэтому ищем байты UTF-8)
cyr=$(printf '[\320\321]')
bad=$(for f in scripts.sh lib/*.sh; do LC_ALL=C grep -n "$cyr" "$f" | LC_ALL=C sed -e "s|^|$f:|"; done \
    | LC_ALL=C grep -vE '^[^:]+:[0-9]+:[[:space:]]*#' \
    | LC_ALL=C sed -e 's/[[:space:]]#[[:space:]].*$//' -e 's/\[YyДд\]//g' -e 's/"Русский"//g' \
    | LC_ALL=C grep "$cyr")
if [ -z "$bad" ]; then ok "нет русских строк вне lang/"; else bad "русский текст вне lang/ (вынесите в словарь через tr_text):"; echo "$bad" | cut -c1-140; fi

# 14. новые модули работают под set -u (опечатка в имени переменной не должна тихо превращаться в пустую строку)
mkdir -p "$tmp/u/data" "$tmp/u/cfg"
if out=$(TMPU="$tmp/u" bash -u -c '
    RED=; GREEN=; YELLOW=; BLUE=; CYAN=; MAGENTA=; NC=; BOLD=; DIM=; SUDO=
    DATA_DIR=$TMPU/data; CONFIG_DIR=$TMPU/cfg; CONFIG_FILE=$CONFIG_DIR/config; LANG_FILE=$CONFIG_DIR/lang.conf
    VERSION=t; LANG_SET=en; REPO_URL=file:///none
    for fn in config_get; do source <(sed -n "/^${fn}() {/,/^}/p" scripts.sh); done
    tr_text() { echo "$1"; }
    for m in pkg common firewall cli; do source lib/$m.sh; done
    config_set lang en; config_get lang >/dev/null
    _log_action 0 smoke "detail"
    run_step smoke true >/dev/null
    pkg_mgr >/dev/null || true
    svc_summary >/dev/null
    cli_status >/dev/null
    rw_cli config list >/dev/null
    rw_cli log 5 >/dev/null
    rw_completion bash >/dev/null; rw_completion zsh >/dev/null
    port_apply open 70000 tcp; prc=$?   # 3 — неверный порт, 2 — нет файрвола (зависит от машины)
    [ "$prc" -eq 3 ] || [ "$prc" -eq 2 ]
' 2>&1); then ok "новые модули под set -u"; else bad "новые модули под set -u:"; echo "$out" | tail -5; fi

# 10. юнит-тесты на bats (если установлен)
if command -v bats >/dev/null 2>&1; then
    if bats tests/bats; then ok "bats tests/bats"; else bad "bats tests/bats"; fi
else
    echo "skip - bats не установлен (apt install bats / apk add bats)"
fi

exit $fail
