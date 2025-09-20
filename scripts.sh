#!/bin/bash
# ====== НАСТРОЙКИ И ПОДГОТОВКА ======
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/remnawave"
CONFIG_DIR="$HOME/.config/remnawave"
SCRIPT_PATH="$HOME/.local/bin/rw-scripts"
REPO_URL="https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main"

# читаем версию
if [ -s "$DATA_DIR/version.txt" ]; then
    VERSION=$(tr -d '\r\n' < "$DATA_DIR/version.txt")
else
    VERSION="dev"
fi

# Цвета
RED='\e[31m'; YELLOW='\e[33m'; GREEN='\e[32m'; BLUE='\e[34m'; NC='\e[0m'

# ====== БАННЕР ======
show_banner() {
    echo -e "${GREEN}"
    if command -v figlet >/dev/null 2>&1; then
        figlet "Remnawave"
        echo -e "             v$VERSION"
    else
        echo "====================================="
        echo "  🚀 Remnawave Scripts (v$VERSION)"
        echo "====================================="
    fi
    echo -e "${NC}"
}

# ====== ТИХАЯ ПРОВЕРКА ОБНОВЛЕНИЙ ======
auto_check_update() {
    local latest
    latest=$(curl -s "$REPO_URL/version.txt" | tr -d '\r\n')
    if [ -n "$latest" ] && [ "$latest" != "$VERSION" ]; then
        echo -e "${YELLOW}⚠️  A new version is available: $latest (you are on $VERSION)"
        echo -e "   Run option [3] in the menu to update.${NC}"
        echo
    fi
}

# ====== СПИННЕР ======
spinner() {
    local pid=$1 delay=0.1 spinstr='|/-\' start_time min_duration=2
    start_time=$(date +%s)
    echo -ne "${YELLOW}"
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep "$delay"
        printf "\b\b\b\b\b\b"
    done
    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    if [ $elapsed -lt $min_duration ]; then
        sleep $((min_duration - elapsed))
    fi
    echo -ne "${NC}"
}

# ====== ЯЗЫК ======
LANG_FILE="$CONFIG_DIR/lang.conf"
LANG_SET="en"
[ -f "$LANG_FILE" ] && LANG_SET=$(<"$LANG_FILE")

# ====== СЛОВАРЬ ======
tr_text() {
    case "$LANG_SET" in
        "ru")
            case "$1" in
                MENU_GEN_IDS) echo "1) Сгенерировать shorts_id" ;;
                MENU_FLAG)    echo "2) Получить emoji-флаг страны" ;;
                MENU_UPDATE)  echo "3) Проверить версию/обновить" ;;
                MENU_DELETE)  echo "4) Удалить rw-scripts" ;;
                MENU_SYSINFO) echo "7) Показать системную информацию" ;;
                MENU_EXIT)    echo "0) Выйти" ;;
                PROMPT_CHOICE) echo -e "${BLUE}Выберите действие:${NC}" ;;
                MSG_EXIT)     echo "Выход... Пока 👋" ;;
                ERR_CHOICE)   echo "Неверный выбор, попробуй ещё раз 😅" ;;
                IDS_HOW_MANY) echo "Сколько идентификаторов сгенерировать?" ;;
                ERR_NUMBER)   echo "Ошибка: введите корректное число!" ;;
                ERR_GT_ZERO)  echo "Ошибка: количество должно быть больше нуля!" ;;
                IDS_DONE)     echo "ID сгенерированы! Вот твой список:" ;;
                ERR_IDS)      echo "Произошла ошибка во время генерации." ;;
                COUNTRY_PROMPT) echo "Введите название страны (на русском или английском, можно часть, 0 = выход в меню):" ;;
                NOTHING_FOUND)  echo "Ничего не найдено по запросу" ;;
                RESULTS)        echo "Результаты поиска:" ;;
                PROMPT_NUM)     echo "Выберите номер (или 0 для нового поиска):" ;;
                ERR_NUM)        echo "Введите корректный номер!" ;;
                ERR_NOT_FOUND)  echo "Нет варианта с таким номером." ;;
                YOU_SELECTED)   echo "Вы выбрали:" ;;
                CHECK_CURR)     echo "Текущая версия:" ;;
                CHECK_LATEST)   echo "Последняя версия:" ;;
                UPDATE_AVAIL)   echo "Есть новая версия! Хотите обновиться? (y/n)" ;;
                UPDATE_DONE)    echo "Скрипт обновлён до версии" ;;
                UPDATE_RESTART) echo "Перезапуск..." ;;
                UPDATE_FAIL)    echo "Не удалось проверить обновления." ;;
                NO_UPDATES)     echo "У вас уже последняя версия." ;;
                CONFIRM_DEL)    echo "Вы уверены, что хотите удалить rw-scripts? (y/n)" ;;
                CANCEL_DEL)     echo "Удаление отменено" ;;
            esac ;;
        "en" | *)
            case "$1" in
                MENU_GEN_IDS) echo "1) Generate shorts_id" ;;
                MENU_FLAG)    echo "2) Get country emoji flag" ;;
                MENU_UPDATE)  echo "3) Check version/update" ;;
                MENU_DELETE)  echo "4) Uninstall rw-scripts" ;;
                MENU_SYSINFO) echo "7) Show system info" ;;
                MENU_EXIT)    echo "0) Exit" ;;
                PROMPT_CHOICE) echo -e "${BLUE}Choose an action:${NC}" ;;
                MSG_EXIT)     echo "Exiting... Bye 👋" ;;
                ERR_CHOICE)   echo "Invalid choice, try again 😅" ;;
                IDS_HOW_MANY) echo "How many IDs to generate?" ;;
                ERR_NUMBER)   echo "Error: enter a valid number!" ;;
                ERR_GT_ZERO)  echo "Error: number must be greater than zero!" ;;
                IDS_DONE)     echo "IDs generated! Here is your list:" ;;
                ERR_IDS)      echo "An error occurred during generation." ;;
                COUNTRY_PROMPT) echo "Enter country name (English or Russian, part allowed, 0 = back to menu):" ;;
                NOTHING_FOUND)  echo "Nothing found for query" ;;
                RESULTS)        echo "Search results:" ;;
                PROMPT_NUM)     echo "Choose number (or 0 for new search):" ;;
                ERR_NUM)        echo "Enter a valid number!" ;;
                ERR_NOT_FOUND)  echo "No option with that number found." ;;
                YOU_SELECTED)   echo "You selected:" ;;
                CHECK_CURR)     echo "Current version:" ;;
                CHECK_LATEST)   echo "Latest version:" ;;
                UPDATE_AVAIL)   echo "New version available! Update? (y/n)" ;;
                UPDATE_DONE)    echo "Script updated to version" ;;
                UPDATE_RESTART) echo "Restarting..." ;;
                UPDATE_FAIL)    echo "Failed to check for updates." ;;
                NO_UPDATES)     echo "You already have the latest version." ;;
                CONFIRM_DEL)    echo "Are you sure you want to uninstall rw-scripts? (y/n)" ;;
                CANCEL_DEL)     echo "Uninstall canceled" ;;
            esac ;;
    esac
}

# ====== ФУНКЦИЯ: СИСТЕМНАЯ ИНФА ======
show_system_info() {
    echo -e "${GREEN}======== 📊 System Information ========${NC}"
    echo -e "${YELLOW}OS:       ${NC}$(uname -srm)"
    echo -e "${YELLOW}Shell:    ${NC}$SHELL"
    echo -e "${YELLOW}Date:     ${NC}$(date)"
    echo -e "${YELLOW}Uptime:   ${NC}$(uptime -p)"

    # CPU info
    if command -v lscpu >/dev/null 2>&1; then
        cpu_model=$(lscpu | grep "Model name:" | sed 's/Model name:\s*//')
        cpu_cores=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    elif [ -f /proc/cpuinfo ]; then
        cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ *//')
        cpu_cores=$(grep -c ^processor /proc/cpuinfo)
    else
        cpu_model="Unknown"
        cpu_cores="?"
    fi
    echo -e "${YELLOW}CPU:      ${NC}$cpu_model ($cpu_cores cores)"

    # RAM
    echo -e "${YELLOW}Free RAM: ${NC}$(free -h | awk '/Mem/ {print $4 " free / " $2 " total"}')"

    # Disk
    echo -e "${YELLOW}Disk:     ${NC}$(df -h --output=pcent / | tail -1) used of /"

    # IP addresses
    local_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    [ -z "$local_ip" ] && local_ip="N/A"
    echo -e "${YELLOW}Local IP: ${NC}$local_ip"

    if command -v curl >/dev/null 2>&1; then
        external_ip=$(curl -s ifconfig.me || curl -s ipinfo.io/ip)
        [ -z "$external_ip" ] && external_ip="N/A"
    else
        external_ip="N/A (curl not installed)"
    fi
    echo -e "${YELLOW}Public IP:${NC} $external_ip"

    echo -e "${GREEN}=======================================${NC}"
}

# ====== ГЕНЕРАЦИЯ ID ======
generate_ids() {
    echo -ne "${BLUE}$(tr_text IDS_HOW_MANY)${NC} "
    read -r count

    # проверка на число
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}$(tr_text ERR_NUMBER)${NC}"
        return
    fi

    # проверка на > 0
    if [ "$count" -le 0 ]; then
        echo -e "${RED}$(tr_text ERR_GT_ZERO)${NC}"
        return
    fi

    echo -e "${GREEN}$(tr_text IDS_DONE)${NC}\n"
    # простая генерация — сразу, построчно
    for ((i=1; i<=count; i++)); do
        id=$(head -c 8 /dev/urandom | xxd -p)
        echo "\"$id\","
    done
}

# ====== ISO→ФЛАГ ======
iso_to_flag() {
    country_code=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    for ((i=0; i<${#country_code}; i++)); do
        char=${country_code:i:1}
        code=$(( $(printf '%d' "'$char") - 65 + 0x1F1E6 ))
        printf "\\U$(printf '%X' $code)"
    done
}

# ====== ПОИСК СТРАН ======
country_lookup() {
    echo "$(tr_text COUNTRY_PROMPT)"
    read input
    key=$(echo "$input" | tr '[:upper:]' '[:lower:]')

    COUNTRIES_FILE="$DATA_DIR/countries.csv"
    if [ ! -f "$COUNTRIES_FILE" ]; then
        echo -e "${RED}countries.csv not found in $DATA_DIR${NC}"
        return
    fi

    matches=$(awk -F',' -v key="$key" '
    {
        ru=tolower($1); en=tolower($2); iso=$3;
        if (ru ~ key || en ~ key) {
            print iso "," $2;
        }
    }' "$COUNTRIES_FILE")

    if [ -z "$matches" ]; then
        echo -e "${RED}$(tr_text NOTHING_FOUND) '${input}'.${NC}"
        return
    fi

    total=$(echo "$matches" | wc -l)
    if [ "$total" -gt 10 ]; then
        echo -e "${YELLOW}Найдено ${total} совпадений. Показать все? (y/n)${NC}"
        read ans
        [[ ! "$ans" =~ ^[YyДд]$ ]] && { echo -e "${RED}Отмена.${NC}"; return; }
    fi

    echo -e "${GREEN}$(tr_text RESULTS)${NC}"
    echo "$matches" | while IFS=',' read -r iso en; do
        flag=$(iso_to_flag "$iso")
        echo " $flag $en"
    done
}

# ====== ОБНОВЛЕНИЕ ======
check_update() {
    local latest tmp_script tmp_version

    latest=$(curl -fsSL "$REPO_URL/version.txt" | tr -d '\r\n')
    [ -z "$latest" ] && { echo -e "${RED}$(tr_text UPDATE_FAIL)${NC}"; return 1; }

    echo "$(tr_text CHECK_CURR) $VERSION"
    echo "$(tr_text CHECK_LATEST) $latest"

    if [ "$VERSION" = "$latest" ]; then
        echo -e "${GREEN}$(tr_text NO_UPDATES)${NC}"
        return 0
    fi

    echo -e "${YELLOW}$(tr_text UPDATE_AVAIL)${NC}"
    read -r ans
    [[ ! "$ans" =~ ^[YyДд]$ ]] && { echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"; return 0; }

    tmp_script="$SCRIPT_PATH.tmp"
    tmp_version="$DATA_DIR/version.txt.tmp"

    curl -fsSL -o "$tmp_script" "$REPO_URL/scripts.sh" || { echo -e "${RED}$(tr_text UPDATE_FAIL)${NC}"; rm -f "$tmp_script"; return 1; }
    curl -fsSL -o "$tmp_version" "$REPO_URL/version.txt" || { echo -e "${RED}$(tr_text UPDATE_FAIL)${NC}"; rm -f "$tmp_*"; return 1; }

    mv "$tmp_script" "$SCRIPT_PATH"; chmod +x "$SCRIPT_PATH"
    mv "$tmp_version" "$DATA_DIR/version.txt"

    echo -e "${GREEN}$(tr_text UPDATE_DONE) $latest${NC}"
    echo -e "${YELLOW}$(tr_text UPDATE_RESTART)${NC}"
    exec "$SCRIPT_PATH"
}

# ====== УДАЛЕНИЕ ======
delete_self() { "$DATA_DIR/uninstall.sh"; exit 0; }

# ====== МЕНЮ ======
show_menu() {
    echo
    echo "$(tr_text PROMPT_CHOICE)"
    echo -e "${YELLOW}$(tr_text MENU_GEN_IDS)${NC}"
    echo -e "${YELLOW}$(tr_text MENU_FLAG)${NC}"
    echo -e "${YELLOW}$(tr_text MENU_UPDATE)${NC}"
    echo -e "${YELLOW}$(tr_text MENU_DELETE)${NC}"
    echo -e "${YELLOW}$(tr_text MENU_SYSINFO)${NC}"
    echo -e "${YELLOW}$(tr_text MENU_EXIT)${NC}"
    echo -n "> "
    read -r choice
    case $choice in
        1) generate_ids ;;
        2) country_lookup ;;
        3) check_update ;;
        4) delete_self ;;
        7) show_system_info ;;
        0) tr_text MSG_EXIT; exit 0 ;;
        *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}" ;;
    esac
}

# ====== ЦИКЛ ======
show_banner
auto_check_update

while true; do
    show_menu
done