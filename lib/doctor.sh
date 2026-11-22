#!/bin/bash
# lib/doctor.sh — диагностика окружения: rw-scripts doctor [--online]
# Подключается из scripts.sh через load_modules; сам по себе не запускается.
# Вывод на английском: его вставляют в баг-репорты и читают в логах CI.
# Код возврата: 0 — всё в порядке (предупреждения допустимы), 1 — есть критичная проблема.

rw_doctor() {
    local online=0 fail=0 warn=0
    [ "${1:-}" = "--online" ] && online=1

    _doc_ok()   { echo -e "  ${GREEN}ok${NC}    $*"; }
    _doc_warn() { echo -e "  ${YELLOW}warn${NC}  $*"; warn=$((warn + 1)); }
    _doc_bad()  { echo -e "  ${RED}FAIL${NC}  $*"; fail=$((fail + 1)); }

    echo "rw-scripts $VERSION — doctor"
    echo

    echo "System"
    _doc_ok "bash ${BASH_VERSION:-unknown}"
    if [ "$(id -u)" -eq 0 ]; then
        _doc_ok "running as root (privilege escalation not needed)"
    elif command -v sudo >/dev/null 2>&1; then
        _doc_ok "sudo available"
    else
        _doc_warn "not root and no sudo: actions that change the system will fail"
    fi
    local pm
    if pm=$(pkg_mgr); then _doc_ok "package manager: $pm"; else _doc_warn "no supported package manager found"; fi
    _doc_ok "firewall: $(detect_firewall)"

    echo
    echo "Required tools"
    local c
    for c in curl awk sed grep; do
        if command -v "$c" >/dev/null 2>&1; then _doc_ok "$c"; else _doc_bad "$c is missing"; fi
    done
    for c in jq tput; do
        if command -v "$c" >/dev/null 2>&1; then _doc_ok "$c"; else _doc_warn "$c is missing (installed or skipped on demand)"; fi
    done

    echo
    echo "Installation"
    if [ -s "$DATA_DIR/version.txt" ]; then _doc_ok "version file: $VERSION"; else _doc_warn "no $DATA_DIR/version.txt (running from a clone?)"; fi
    if [ "$(tr_text MENU_EXIT)" != "MENU_EXIT" ]; then _doc_ok "dictionary loaded (lang: $LANG_SET)"; else _doc_bad "dictionary not loaded"; fi
    local fn missing=0
    for fn in show_main_menu submenu_cleaner submenu_warp submenu_hysteria2 submenu_network submenu_scanner pkg_install; do
        declare -F "$fn" >/dev/null || { _doc_bad "function $fn is not defined (module missing?)"; missing=1; }
    done
    [ "$missing" -eq 0 ] && _doc_ok "all modules loaded"
    if [ -s "$DATA_DIR/countries.csv" ] || [ -s "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")/countries.csv" ]; then
        _doc_ok "countries.csv"
    else
        _doc_warn "countries.csv not found (country search will not work)"
    fi

    if [ "$online" -eq 1 ]; then
        echo
        echo "Network"
        local latest
        latest=$(curl -fsS --connect-timeout 5 -m 10 "$REPO_URL/version.txt" 2>/dev/null | tr -d '\r\n')
        if [ -z "$latest" ]; then
            _doc_bad "cannot reach $REPO_URL"
        elif [ "$latest" = "$VERSION" ]; then
            _doc_ok "up to date ($latest)"
        else
            _doc_warn "update available: $latest (installed $VERSION)"
        fi
    fi

    echo
    echo "Result: $fail problem(s), $warn warning(s)"
    [ "$fail" -eq 0 ]
}
