#!/bin/bash
# lib/common.sh — общие помощники: настройки, журнал действий, run_step, безопасный запуск сторонних скриптов
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

# ====== НАСТРОЙКИ ======
# Файл $CONFIG_DIR/config, строки вида ключ=значение. Ключи: lang (ru|en), color (auto|always|never).
# Чтение — config_get из scripts.sh (нужно до загрузки модулей).
# config_set ключ значение — создаёт файл при необходимости, заменяет прежнее значение
config_set() {
    local key="$1" val="$2" tmp
    mkdir -p "$(dirname "$CONFIG_FILE")" || return 1
    tmp=$(mktemp) || return 1
    { [ -f "$CONFIG_FILE" ] && grep -v "^$key=" "$CONFIG_FILE"; printf '%s=%s\n' "$key" "$val"; } > "$tmp"
    mv "$tmp" "$CONFIG_FILE"
    # старые версии (после отката) читают язык из lang.conf
    [ "$key" = "lang" ] && printf '%s\n' "$val" > "$LANG_FILE"
    return 0
}

# ====== ЖУРНАЛ ДЕЙСТВИЙ ======
# $DATA_DIR/actions.log: дата, код возврата, описание. Хранится до 256 КБ, затем старый журнал уходит в actions.log.1
RW_LOG="$DATA_DIR/actions.log"

# _log_action КОД ОПИСАНИЕ [ПОДРОБНОСТИ] — подробности ограничены 20 строками
_log_action() {
    local rc="$1" desc="$2" detail="${3:-}" size
    mkdir -p "$DATA_DIR" 2>/dev/null || return 0
    if [ -f "$RW_LOG" ]; then
        size=$(wc -c < "$RW_LOG")
        [ "${size:-0}" -gt 262144 ] && mv -f "$RW_LOG" "$RW_LOG.1"
    fi
    {
        printf '%s rc=%s %s\n' "$(date '+%F %T')" "$rc" "$desc"
        [ -n "$detail" ] && printf '%s\n' "$detail" | head -n 20 | sed 's/^/    /'
    } >> "$RW_LOG" 2>/dev/null
    return 0
}

# ====== ШАГ С РЕАЛЬНЫМ РЕЗУЛЬТАТОМ ======
# run_step "описание" команда [аргументы...]
# Запускает команду, показывает ✅/❌ по её коду возврата (а не «успех» по умолчанию), пишет вывод в журнал.
# При ошибке печатает последние строки вывода. Возвращает код команды.
run_step() {
    local desc="$1" out rc
    shift
    out=$("$@" 2>&1)
    rc=$?
    _log_action "$rc" "$desc" "$out"
    if [ "$rc" -eq 0 ]; then
        echo -e "${GREEN}✅ $desc${NC}"
    else
        echo -e "${RED}❌ $desc (rc=$rc)${NC}"
        [ -n "$out" ] && printf '%s\n' "$out" | tail -n 5 | sed 's/^/   /'
    fi
    return "$rc"
}

# ====== СТОРОННИЕ СКРИПТЫ ======
# _remote_fetch URL — качает во временный файл, показывает размер и SHA256, спрашивает подтверждение.
# Результат: путь во временный файл в REMOTE_TMP, хэш в REMOTE_HASH. Коды: 0 можно запускать, 1 ошибка, 3 отказ.
# Необязательно: RW_EXPECT_SHA256 — ожидаемый хэш; при несовпадении запуск отменяется без вопросов.
_remote_fetch() {
    local url="$1" size ans
    REMOTE_TMP=$(mktemp) || return 1
    if ! curl -fsSL --connect-timeout 10 -m 120 -o "$REMOTE_TMP" "$url"; then
        rm -f "$REMOTE_TMP"
        echo -e "${RED}❌ $(tr_text RS_DL_FAIL)${NC}"
        _log_action 1 "remote script download failed: $url"
        return 1
    fi
    REMOTE_HASH=$(sha256sum "$REMOTE_TMP" 2>/dev/null | cut -d' ' -f1)
    [ -n "$REMOTE_HASH" ] || REMOTE_HASH=$(shasum -a 256 "$REMOTE_TMP" 2>/dev/null | cut -d' ' -f1)
    [ -n "$REMOTE_HASH" ] || { rm -f "$REMOTE_TMP"; echo -e "${RED}❌ $(tr_text RS_DL_FAIL)${NC}"; return 1; }
    size=$(wc -c < "$REMOTE_TMP" | tr -d ' ')
    echo -e "${CYAN}$(tr_text RS_FETCHED)${NC} $url"
    echo "  SHA256: $REMOTE_HASH"
    echo "  $size bytes"

    if [ -n "${RW_EXPECT_SHA256:-}" ] && [ "$RW_EXPECT_SHA256" != "$REMOTE_HASH" ]; then
        rm -f "$REMOTE_TMP"
        echo -e "${RED}❌ $(tr_text RS_HASH_BAD)${NC}"
        _log_action 3 "remote script hash mismatch: $url"
        return 1
    fi

    while true; do
        read -rp "$(tr_text RS_ASK) " ans
        case "$ans" in
            [YyДд]) break ;;
            [Vv]) "${PAGER:-less}" "$REMOTE_TMP" 2>/dev/null || head -n 120 "$REMOTE_TMP" ;;
            *) rm -f "$REMOTE_TMP"; echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"; _log_action 3 "remote script declined: $url"; return 3 ;;
        esac
    done

    # копия того, что запускалось, для последующего разбора
    mkdir -p "$DATA_DIR/third-party" 2>/dev/null \
        && cp "$REMOTE_TMP" "$DATA_DIR/third-party/$(basename "${url%%\?*}")-${REMOTE_HASH:0:12}" 2>/dev/null
    return 0
}

# run_remote_script [--sh] URL [аргументы скрипта...] — безопасная замена bash <(curl ...)
run_remote_script() {
    local interp=bash rc url
    [ "${1:-}" = "--sh" ] && { interp="sh"; shift; }
    url="$1"; shift
    _remote_fetch "$url" || return $?
    "$interp" "$REMOTE_TMP" "$@"
    rc=$?
    rm -f "$REMOTE_TMP"
    _log_action "$rc" "remote script run: $url $*"
    return "$rc"
}

# install_remote_script URL ПУТЬ — скачивает, показывает хэш, спрашивает и ставит файл как исполняемый (для готовых утилит)
install_remote_script() {
    local url="$1" dest="$2" rc=0
    _remote_fetch "$url" || return $?
    $SUDO install -m 755 "$REMOTE_TMP" "$dest" || rc=$?
    rm -f "$REMOTE_TMP"
    _log_action "$rc" "remote script installed: $url -> $dest"
    return "$rc"
}
