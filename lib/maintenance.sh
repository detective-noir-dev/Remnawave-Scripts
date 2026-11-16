#!/bin/bash
# lib/maintenance.sh — Обновление rw-scripts, удаление, обновление пакетов системы
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

# ====== ОБНОВЛЕНИЕ ======
check_update() {
    local latest
    latest=$(curl -fsSL "$REPO_URL/version.txt" | tr -d '\r\n')
    [ -z "$latest" ] && { echo -e "${RED}$(tr_text UPDATE_FAIL)${NC}"; read -rp "$(tr_text PRESS_ENTER)"; return 1; }
    
    echo "$(tr_text CHECK_CURR) $VERSION"
    echo "$(tr_text CHECK_LATEST) $latest"
    
    if [ "$VERSION" = "$latest" ]; then
        echo -e "${GREEN}$(tr_text NO_UPDATES)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi
    
    echo -e "${YELLOW}$(tr_text UPDATE_AVAIL)${NC}"
    read -r ans
    [[ ! "$ans" =~ ^[YyДд]$ ]] && { echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"; return 0; }
    
    # всё качаем в staging и сверяем с SHA256SUMS; ставим только если проверены все файлы
    local stage="$DATA_DIR/.update.$$" sums name rc=0 msg
    local files=(scripts.sh lang/ru.sh lang/en.sh version.txt uninstall.sh countries.csv)
    mkdir -p "$stage/lang" "$stage/lib"

    echo -e "${BLUE}⏳ Downloading...${NC}"
    loading_bar & pid=$!

    sums=$(curl -fsSL "$REPO_URL/SHA256SUMS" 2>/dev/null)
    if [ -z "$sums" ]; then
        rc=2
    else
        # модули lib/*.sh берём из списка в SHA256SUMS: новый модуль подхватится без правок кода
        while read -r name; do
            [ -n "$name" ] && files+=("$name")
        done < <(_lib_names "$sums")
        for name in "${files[@]}"; do
            fetch_verified "$name" "$stage/$name" "$sums" || { rc=$?; break; }
        done
        # без модулей новая версия не запустится: не ставим
        [ "$rc" -eq 0 ] && [ ! -s "$stage/lib/pkg.sh" ] && rc=2
    fi

    kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm

    if [ "$rc" -ne 0 ]; then
        case "$rc" in
            1) msg=$(tr_text UPDATE_FAIL) ;;
            3) msg=$(tr_text UPDATE_BAD_HASH) ;;
            *) msg=$(tr_text UPDATE_NO_HASH) ;;
        esac
        echo -e "\r${RED}${msg}${NC}          "
        rm -rf "$stage"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    # прежняя версия остаётся в $DATA_DIR/previous: вернуться можно пунктом «Откатить» или rw-scripts rollback
    _backup_current

    # скрипт заменяем последним: если что-то оборвётся раньше, старая версия остаётся рабочей
    mkdir -p "$LANG_DIR"
    mv "$stage/lang/ru.sh" "$stage/lang/en.sh" "$LANG_DIR/"
    rm -rf "$LIB_DIR"; mv "$stage/lib" "$LIB_DIR"
    chmod +x "$stage/uninstall.sh"
    mv "$stage/uninstall.sh" "$stage/countries.csv" "$DATA_DIR/"
    printf '%s\n' "$sums" > "$DATA_DIR/SHA256SUMS"   # по нему работает rw-scripts verify
    mv "$stage/version.txt" "$DATA_DIR/version.txt"
    chmod +x "$stage/scripts.sh"
    mv "$stage/scripts.sh" "$SCRIPT_PATH"
    rm -rf "$stage"

    echo -e "\r${GREEN}$(tr_text UPDATE_DONE) $latest${NC}     "
    echo -e "${YELLOW}$(tr_text UPDATE_RESTART)${NC}"
    exec "$SCRIPT_PATH"
}

# ====== РЕЗЕРВНАЯ КОПИЯ, ОТКАТ И ПРОВЕРКА ЦЕЛОСТНОСТИ ======
PREV_DIR="$DATA_DIR/previous"

# _snapshot DEST — копия установленной версии: скрипт, модули, словари, version.txt, SHA256SUMS
_snapshot() {
    local dest="$1" f
    rm -rf "$dest"; mkdir -p "$dest" || return 1
    cp "$SCRIPT_PATH" "$dest/scripts.sh" || { rm -rf "$dest"; return 1; }
    [ -d "$LIB_DIR" ] && cp -r "$LIB_DIR" "$dest/lib"
    [ -d "$LANG_DIR" ] && cp -r "$LANG_DIR" "$dest/lang"
    for f in version.txt SHA256SUMS; do
        [ -f "$DATA_DIR/$f" ] && cp "$DATA_DIR/$f" "$dest/$f"
    done
    return 0
}

# _backup_current — запоминает установленную версию перед обновлением (одна копия, прежняя затирается)
_backup_current() {
    [ -f "$SCRIPT_PATH" ] || return 0     # запуск из клона: копировать нечего
    _snapshot "$DATA_DIR/previous.new" || return 1
    rm -rf "${PREV_DIR:?}"
    mv "$DATA_DIR/previous.new" "$PREV_DIR"
}

# _verify_layout SUMS SCRIPT LIBDIR LANGDIR DATADIR STRICT
# Сверяет файлы с SHA256SUMS, печатает только расхождения. Код возврата: число расхождений (99 — нет sha256sum).
# STRICT=1: отсутствующий файл считается расхождением; 0: пропускается (так проверяется копия для отката).
# Число проверенных файлов остаётся в VERIFY_CHECKED.
_verify_layout() {
    local sums="$1" script="$2" libdir="$3" langdir="$4" datadir="$5" strict="$6"
    local bad=0 hash name path actual
    VERIFY_CHECKED=0
    while read -r hash name; do
        [ -n "$hash" ] || continue
        name="${name#\*}"
        case "$name" in
            scripts.sh) path="$script" ;;
            lib/*)      path="$libdir/${name#lib/}" ;;
            lang/*)     path="$langdir/${name#lang/}" ;;
            *)          path="$datadir/$name" ;;
        esac
        if [ ! -f "$path" ]; then
            if [ "$strict" = 1 ]; then
                echo -e "  ${RED}missing${NC}  $name"
                bad=$((bad + 1))
            fi
            continue
        fi
        actual=$(_sha256_of "$path") || return 99
        VERIFY_CHECKED=$((VERIFY_CHECKED + 1))
        if [ "$actual" != "$hash" ]; then
            echo -e "  ${RED}CHANGED${NC}  $name"
            bad=$((bad + 1))
        fi
    done <<<"$sums"
    return "$bad"
}

# verify_install [--online] — сверка установленных файлов с SHA256SUMS.
# По умолчанию берётся копия, сохранённая при установке/обновлении; --online сравнивает с репозиторием (нужна та же версия).
verify_install() {
    local sums src rc
    if [ "${1:-}" = "--online" ]; then
        src="online"
        sums=$(curl -fsSL --connect-timeout 5 -m 15 "$REPO_URL/SHA256SUMS" 2>/dev/null)
    else
        src="local"
        sums=$(cat "$DATA_DIR/SHA256SUMS" 2>/dev/null)
    fi
    if [ -z "$sums" ]; then
        echo -e "${YELLOW}$(tr_text VERIFY_NO_SUMS)${NC}"
        return 2
    fi
    echo "$(tr_text VERIFY_TITLE) v$VERSION ($src SHA256SUMS)"
    _verify_layout "$sums" "$SCRIPT_PATH" "$LIB_DIR" "$LANG_DIR" "$DATA_DIR" 1
    rc=$?
    case "$rc" in
        0)  echo -e "${GREEN}✅ $(tr_text VERIFY_OK) ($VERIFY_CHECKED)${NC}" ;;
        99) echo -e "${RED}❌ $(tr_text UPDATE_NO_HASH)${NC}" ;;
        *)  echo -e "${RED}❌ $(tr_text VERIFY_BAD)${NC}" ;;
    esac
    return "$rc"
}

# rollback_update [--yes] — вернуть версию, сохранённую перед последним обновлением.
# Текущая версия при этом становится «предыдущей», так что откат можно отменить тем же пунктом.
# Коды: 0 откат выполнен, 1 ошибка или нет копии, 3 отменено пользователем.
rollback_update() {
    local yes=0 pv ans f swap="$DATA_DIR/previous.swap"
    [ "${1:-}" = "--yes" ] && yes=1

    if [ ! -s "$PREV_DIR/scripts.sh" ] || [ ! -s "$PREV_DIR/lib/pkg.sh" ]; then
        echo -e "${YELLOW}$(tr_text ROLLBACK_NONE)${NC}"
        return 1
    fi
    pv=$(tr -d '\r\n' < "$PREV_DIR/version.txt" 2>/dev/null)
    echo "$(tr_text CHECK_CURR) $VERSION"
    echo "$(tr_text ROLLBACK_TARGET) ${pv:-?}"

    # копия не должна быть повреждена: сверяем с её собственным SHA256SUMS, если он сохранён
    if [ -s "$PREV_DIR/SHA256SUMS" ]; then
        if ! _verify_layout "$(cat "$PREV_DIR/SHA256SUMS")" "$PREV_DIR/scripts.sh" "$PREV_DIR/lib" "$PREV_DIR/lang" "$PREV_DIR" 0; then
            echo -e "${RED}❌ $(tr_text ROLLBACK_BAD)${NC}"
            return 1
        fi
    fi

    if [ "$yes" -ne 1 ]; then
        read -rp "$(tr_text ROLLBACK_ASK) " ans
        [[ "$ans" =~ ^[YyДд]$ ]] || { echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"; return 3; }
    fi

    _snapshot "$swap" || { rm -rf "$swap"; echo -e "${RED}❌ $(tr_text ROLLBACK_FAIL)${NC}"; return 1; }

    # модули и словари, затем скрипт последним: оборванный откат не оставляет нерабочий скрипт
    rm -rf "${LIB_DIR:?}"; cp -r "$PREV_DIR/lib" "$LIB_DIR" || { echo -e "${RED}❌ $(tr_text ROLLBACK_FAIL)${NC}"; return 1; }
    if [ -d "$PREV_DIR/lang" ]; then
        rm -rf "${LANG_DIR:?}"; cp -r "$PREV_DIR/lang" "$LANG_DIR"
    fi
    for f in version.txt SHA256SUMS; do
        [ -f "$PREV_DIR/$f" ] && cp "$PREV_DIR/$f" "$DATA_DIR/$f"
    done
    cp "$PREV_DIR/scripts.sh" "$SCRIPT_PATH.new" && chmod +x "$SCRIPT_PATH.new" && mv "$SCRIPT_PATH.new" "$SCRIPT_PATH" \
        || { echo -e "${RED}❌ $(tr_text ROLLBACK_FAIL)${NC}"; return 1; }

    rm -rf "${PREV_DIR:?}"; mv "$swap" "$PREV_DIR"
    echo -e "${GREEN}✅ $(tr_text ROLLBACK_DONE) ${pv:-?}${NC}"
    return 0
}

# ====== УДАЛЕНИЕ ======
delete_self() {
    echo -e "${RED}$(tr_text CONFIRM_DEL)${NC}"
    read -r ans
    if [[ "$ans" =~ ^[YyДд]$ ]]; then
        "$DATA_DIR/uninstall.sh"
        # uninstall.sh сам спрашивает подтверждение: выходим, только если скрипт реально удалён
        [ -e "$SCRIPT_PATH" ] || exit 0
        return 0
    fi
    echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
}

# ====== ОБНОВЛЕНИЕ СИСТЕМНЫХ ПАКЕТОВ ======
apt_update_upgrade() {
    # Проверяем наличие apt
    if ! command -v apt >/dev/null 2>&1 && ! command -v apt-get >/dev/null 2>&1; then
        echo -e "${RED}❌ $(tr_text APT_NOT_FOUND)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    echo -e "${YELLOW}$(tr_text APT_CONFIRM)${NC}"
    read -r ans
    
    if [[ ! "$ans" =~ ^[YyДд]$ ]]; then
        echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi
    
    echo -e "${BLUE}📦 $(tr_text APT_UPDATING)${NC}"
    
    # Запускаем крутилку
    loading_bar & 
    local spinner_pid=$!
    
    # Выполняем apt update в фоне, скрывая вывод
    if command -v apt >/dev/null 2>&1; then
        $SUDO apt update &>/dev/null
        local update_status=$?
    else
        $SUDO apt-get update &>/dev/null
        local update_status=$?
    fi
    
    # Останавливаем крутилку
    kill $spinner_pid >/dev/null 2>&1
    wait $spinner_pid 2>/dev/null
    tput cnorm
    
    # Проверяем статус update
    if [ $update_status -ne 0 ]; then
        echo -e "\r${RED}❌ $(tr_text APT_UPDATE_FAIL)${NC}                    "
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    echo -e "\r${GREEN}✅ $(tr_text APT_UPDATE_OK)${NC}                    "
    echo
    echo -e "${BLUE}⬆️  $(tr_text APT_UPGRADING)${NC}"
    
    # Запускаем крутилку для upgrade
    loading_bar & 
    spinner_pid=$!
    
    # Выполняем apt upgrade в фоне
    if command -v apt >/dev/null 2>&1; then
        $SUDO apt upgrade -y &>/dev/null
        local upgrade_status=$?
    else
        $SUDO apt-get upgrade -y &>/dev/null
        local upgrade_status=$?
    fi
    
    # Останавливаем крутилку
    kill $spinner_pid >/dev/null 2>&1
    wait $spinner_pid 2>/dev/null
    tput cnorm
    
    # Проверяем статус upgrade
    if [ $upgrade_status -ne 0 ]; then
        echo -e "\r${RED}❌ $(tr_text APT_UPGRADE_FAIL)${NC}                    "
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    echo -e "\r${GREEN}✅ $(tr_text APT_DONE)${NC}                    "
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}
