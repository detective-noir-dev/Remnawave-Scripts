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
    local files=(scripts.sh lang/ru.sh lang/en.sh version.txt)
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

    # скрипт заменяем последним: если что-то оборвётся раньше, старая версия остаётся рабочей
    mkdir -p "$LANG_DIR"
    mv "$stage/lang/ru.sh" "$stage/lang/en.sh" "$LANG_DIR/"
    rm -rf "$LIB_DIR"; mv "$stage/lib" "$LIB_DIR"
    mv "$stage/version.txt" "$DATA_DIR/version.txt"
    chmod +x "$stage/scripts.sh"
    mv "$stage/scripts.sh" "$SCRIPT_PATH"
    rm -rf "$stage"

    echo -e "\r${GREEN}$(tr_text UPDATE_DONE) $latest${NC}     "
    echo -e "${YELLOW}$(tr_text UPDATE_RESTART)${NC}"
    exec "$SCRIPT_PATH"
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
