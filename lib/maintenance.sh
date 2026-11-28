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
    [[ ! "$ans" =~ ^[YyДд]$ ]] && { echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"; read -rp "$(tr_text PRESS_ENTER)"; return 0; }
    
    # сначала скачиваем файлы в staging; текущая установка заменяется после успешной загрузки
    local stage="$DATA_DIR/.update.$$" name rc=0
    local files=(scripts.sh lang/ru.sh lang/en.sh version.txt uninstall.sh countries.csv)
    mkdir -p "$stage/lang" "$stage/lib"

    echo -e "${BLUE}⏳ Downloading...${NC}"
    loading_bar & pid=$!

    local modules=(lib/pkg.sh lib/common.sh lib/firewall.sh lib/cli.sh lib/cleaner.sh lib/dante.sh lib/doctor.sh lib/hy2.sh lib/ids.sh lib/maintenance.sh lib/memory.sh lib/menus.sh lib/scanner.sh lib/server.sh lib/system.sh lib/thirdparty.sh lib/warp.sh)
    files+=("${modules[@]}")
    for name in "${files[@]}"; do
        mkdir -p "$(dirname "$stage/$name")"
        curl -fsSL --connect-timeout 10 -m 120 "$REPO_URL/$name" -o "$stage/$name" || { rc=1; break; }
    done

    kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm

    if [ "$rc" -ne 0 ]; then
        echo -e "\r${RED}$(tr_text UPDATE_FAIL)${NC}          "
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
    mv "$stage/version.txt" "$DATA_DIR/version.txt"
    chmod +x "$stage/scripts.sh"
    mv "$stage/scripts.sh" "$SCRIPT_PATH"
    rm -rf "$stage"

    echo -e "\r${GREEN}$(tr_text UPDATE_DONE) $latest${NC}     "
    echo -e "${YELLOW}$(tr_text UPDATE_RESTART)${NC}"
    exec "$SCRIPT_PATH"
}

# ====== РЕЗЕРВНАЯ КОПИЯ И ОТКАТ ======
PREV_DIR="$DATA_DIR/previous"

# _snapshot DEST — копия установленной версии: скрипт, модули, словари и version.txt
_snapshot() {
    local dest="$1" f
    rm -rf "$dest"; mkdir -p "$dest" || return 1
    cp "$SCRIPT_PATH" "$dest/scripts.sh" || { rm -rf "$dest"; return 1; }
    [ -d "$LIB_DIR" ] && cp -r "$LIB_DIR" "$dest/lib"
    [ -d "$LANG_DIR" ] && cp -r "$LANG_DIR" "$dest/lang"
    [ -f "$DATA_DIR/version.txt" ] && cp "$DATA_DIR/version.txt" "$dest/version.txt"
    return 0
}

# _backup_current — запоминает установленную версию перед обновлением (одна копия, прежняя затирается)
_backup_current() {
    [ -f "$SCRIPT_PATH" ] || return 0     # запуск из клона: копировать нечего
    _snapshot "$DATA_DIR/previous.new" || return 1
    rm -rf "${PREV_DIR:?}"
    mv "$DATA_DIR/previous.new" "$PREV_DIR"
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
    [ -f "$PREV_DIR/version.txt" ] && cp "$PREV_DIR/version.txt" "$DATA_DIR/version.txt"
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
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi
    echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
    read -rp "$(tr_text PRESS_ENTER)"
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
    
    # вывод скрыт, поэтому вопросы debconf и dpkg о конфигах отключены: иначе обновление ждёт невидимого ответа
    $SUDO env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --with-new-pkgs \
        -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold </dev/null &>/dev/null
    local upgrade_status=$?

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
