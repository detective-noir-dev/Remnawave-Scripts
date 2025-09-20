#!/bin/bash
#
# Remnawave Scripts
#

# ====== НАСТРОЙКИ И ПОДГОТОВКА ======
if [ -L "$0" ]; then
    # раскрываем симлинк
    SCRIPT_PATH="$(readlink "$0")"
    SCRIPT_DIR="$( cd -- "$( dirname -- "$SCRIPT_PATH" )" && pwd )"
else
    SCRIPT_PATH="$0"
    SCRIPT_DIR="$( cd -- "$( dirname -- "$SCRIPT_PATH" )" && pwd )"
fi

REPO_URL="https://github.com/detective-noir-dev/Remnawave-Scripts.git"

# Цвета
RED='\e[31m'; YELLOW='\e[33m'; GREEN='\e[32m'; NC='\e[0m'

# Версия
if [ -s "$SCRIPT_DIR/version.txt" ]; then
    VERSION=$(tr -d '\r\n' < "$SCRIPT_DIR/version.txt")
else
    VERSION="dev"
fi

# ====== БАННЕР ======
show_banner() {
    echo -e "${GREEN}"
    echo "====================================="
    echo "  🚀 Remnawave Scripts (v$VERSION)"
    echo "====================================="
    echo -e "${NC}"
}

# ====== ТИХАЯ ПРОВЕРКА ОБНОВЛЕНИЙ (git) ======
auto_check_update() {
    if [ ! -d "$SCRIPT_DIR/.git" ]; then
        return
    fi
    git -C "$SCRIPT_DIR" fetch --quiet
    local_ver=$(<"$SCRIPT_DIR/version.txt")
    remote_ver=$(git -C "$SCRIPT_DIR" show origin/main:version.txt 2>/dev/null | tr -d '\r\n')
    if [ -n "$remote_ver" ] && [ "$remote_ver" != "$local_ver" ]; then
        echo -e "${YELLOW}⚠️  A new version is available: $remote_ver (you are on $local_ver)"
        echo -e "   Run option [3] in the menu to update.${NC}\n"
    fi
}

# ====== СПИННЕР ======
spinner() {
    local pid=$1 delay=0.1 spinstr='|/-\' start_time min_duration=3
    start_time=$(date +%s)
    echo -ne "${YELLOW}"
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep "$delay"
        printf "\b\b\b\b\b\b"
    done
    local end_time elapsed
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    if [ $elapsed -lt $min_duration ]; then
        sleep $((min_duration - elapsed))
    fi
    echo -ne "${NC}"
}

# ====== ЯЗЫК ======
CONFIG_DIR="$HOME/.config/remnawave"
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
                MENU_EXIT)    echo "0) Выйти" ;;
                PROMPT_CHOICE) echo "Выберите действие:" ;;
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
                UPDATE_CANCELLED) echo "Обновление отменено" ;;
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
                MENU_EXIT)    echo "0) Exit" ;;
                PROMPT_CHOICE) echo "Choose an action:" ;;
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
                UPDATE_CANCELLED) echo "Update cancelled" ;;
                NO_UPDATES)     echo "You already have the latest version." ;;
                CONFIRM_DEL)    echo "Are you sure you want to uninstall rw-scripts? (y/n)" ;;
                CANCEL_DEL)     echo "Uninstall cancelled" ;;
            esac ;;
    esac
}

# ====== ГЕНЕРАЦИЯ ID ======
generate_ids() {
    echo "$(tr_text IDS_HOW_MANY)"
    read -r count
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}$(tr_text ERR_NUMBER)${NC}"
        return
    fi
    if [ "$count" -le 0 ]; then
        echo -e "${RED}$(tr_text ERR_GT_ZERO)${NC}"
        return
    fi

    echo -e "${GREEN}$(tr_text IDS_DONE)${NC}\n"
    for ((i=1; i<=count; i++)); do
        id=$(head -c 8 /dev/urandom | xxd -p)
        printf '"%s",\n' "$id"
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
    read -r input
    key=$(echo "$input" | tr '[:upper:]' '[:lower:]')

    matches=$(awk -F',' -v key="$key" '
    {
        ru=tolower($1); en=tolower($2); iso=$3;
        if (ru ~ key || en ~ key) {
            print iso "," $2;
        }
    }' "$SCRIPT_DIR/countries.csv")

    if [ -z "$matches" ]; then
        echo -e "${RED}$(tr_text NOTHING_FOUND) '${input}'.${NC}"
        return
    fi

    echo -e "${GREEN}$(tr_text RESULTS)${NC}"
    echo "$matches" | while IFS=',' read -r iso en; do
        flag=$(iso_to_flag "$iso")
        echo " $flag $en"
    done
}

# ====== ОБНОВЛЕНИЕ (git) ======
check_update() {
    # Показываем текущую локальную версию
    echo "$(tr_text CHECK_CURR) $VERSION"

    # Проверяем, что это git-клон
    if [ ! -d "$SCRIPT_DIR/.git" ]; then
        echo -e "${RED}❌ This installation is not a git clone. Update via installer instead.${NC}"
        return 1
    fi

    # --- Получаем последнюю версию из origin ---
    echo -e "${YELLOW}🔄 Checking for updates via git...${NC}"
    git -C "$SCRIPT_DIR" fetch --quiet

    local local_ver remote_ver
    local_ver=$(<"$SCRIPT_DIR/version.txt")
    remote_ver=$(git -C "$SCRIPT_DIR" show origin/main:version.txt 2>/dev/null | tr -d '\r\n')

    echo "$(tr_text CHECK_LATEST) $remote_ver"

    # --- Если версии совпадают ---
    if [ "$local_ver" = "$remote_ver" ]; then
        echo -e "${GREEN}$(tr_text NO_UPDATES)${NC}"
        return 0
    fi

    # --- Предлагаем обновление ---
    echo -e "${YELLOW}$(tr_text UPDATE_AVAIL)${NC}"
    read -r ans
    if [[ ! "$ans" =~ ^[YyДд]$ ]]; then
        echo -e "${YELLOW}$(tr_text UPDATE_CANCELLED)${NC}"
        return 0
    fi

    # --- Делаем обновление (git pull) ---
    if git -C "$SCRIPT_DIR" pull --ff-only; then
        chmod +x "$SCRIPT_DIR/scripts.sh"
        VERSION=$(<"$SCRIPT_DIR/version.txt")

        # --- Сообщаем об успешной установке ---
        echo -e "${GREEN}$(tr_text UPDATE_DONE) $VERSION${NC}"
        echo -e "${YELLOW}$(tr_text UPDATE_RESTART)${NC}"

        exec "$SCRIPT_DIR/scripts.sh"
    else
        # --- Сообщаем о неудаче обновления ---
        echo -e "${RED}$(tr_text UPDATE_FAIL)${NC}"
        return 1
    fi
}

# ====== УДАЛЕНИЕ ======
delete_self() { "$SCRIPT_DIR/uninstall.sh"; exit 0; }

# ====== МЕНЮ ======
show_menu() {
    echo
    tr_text PROMPT_CHOICE
    tr_text MENU_GEN_IDS
    tr_text MENU_FLAG
    tr_text MENU_UPDATE
    tr_text MENU_DELETE
    tr_text MENU_EXIT
    read -r choice
    case $choice in
        1) generate_ids ;;
        2) country_lookup ;;
        3) check_update ;;
        4) delete_self ;;
        0) tr_text MSG_EXIT; exit 0 ;;
        *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}" ;;
    esac
}

# ====== ЗАПУСК ======
show_banner
auto_check_update

while true; do
    show_menu
done