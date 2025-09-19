#!/bin/bash
# ====== НАСТРОЙКИ И ПОДГОТОВКА ======
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "$SCRIPT_DIR/version.txt" ]; then
    VERSION=$(<"$SCRIPT_DIR/version.txt")
else
    VERSION="dev"
fi

# Цвета
RED='\e[31m'; YELLOW='\e[33m'; GREEN='\e[32m'; NC='\e[0m'

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
                NO_UPDATES)     echo "You already have the latest version." ;;
                CONFIRM_DEL)    echo "Are you sure you want to uninstall rw-scripts? (y/n)" ;;
                CANCEL_DEL)     echo "Uninstall canceled" ;;
            esac ;;
    esac
}

# ====== ГЕНЕРАЦИЯ ID ======
generate_ids() {
    echo "$(tr_text IDS_HOW_MANY)"
    read -r count
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}$(tr_text ERR_NUMBER)${NC}"; return
    fi
    if [ "$count" -le 0 ]; then
        echo -e "${RED}$(tr_text ERR_GT_ZERO)${NC}"; return
    fi

    { for ((i=1; i<=count; i++)); do
          id=$(head -c 8 /dev/urandom | xxd -p)
          printf '"%s",\n' "$id"
      done } > /tmp/ids_output.txt &

    pid=$!; spinner "$pid"; wait "$pid"
    if [ $? -ne 0 ]; then
        echo -e "${RED}$(tr_text ERR_IDS)${NC}"; return
    fi
    echo -e "${GREEN}$(tr_text IDS_DONE)${NC}\n"; cat /tmp/ids_output.txt; echo -e "\a"
}

# ====== ISO → FLAG ======
iso_to_flag() {
    ISO_CODE="$1" python3 - <<'EOF'
import sys, os
code = os.environ.get("ISO_CODE", "").upper()
flag = "".join([chr(127397 + ord(c)) for c in code])
sys.stdout.buffer.write(flag.encode("utf-8"))
EOF
}

# ====== ПОИСК СТРАН ======
country_lookup() {
    while true; do
        echo "$(tr_text COUNTRY_PROMPT)"
        read -r input; [ "$input" = "0" ] && return
        matches=$(awk -F',' -v key="$input" '
        BEGIN { key=tolower(key); i=0 }
        {
            ru=tolower($1); en=tolower($2); iso=$3;
            gsub(/\r$/,"",ru); gsub(/\r$/,"",en);
            if (ru ~ key || en ~ key) {
                print iso "," en;
            }
        }' "$SCRIPT_DIR/countries.csv")
        if [ -z "$matches" ]; then
            echo -e "${RED}$(tr_text NOTHING_FOUND) '$input'.${NC}"; continue
        fi
        echo -e "${GREEN}$(tr_text RESULTS)${NC}"
        i=1
        echo "$matches" | while IFS=',' read -r iso en; do
            flag=$(iso_to_flag "$iso")
            printf " %s) %s %s\n" "$i" "$flag" "$en"
            i=$((i+1))
        done > /tmp/matches_list.txt
        cat /tmp/matches_list.txt
        echo "$(tr_text PROMPT_NUM)"; read -r choice
        [ "$choice" = "0" ] && continue
        if ! [[ "$choice" =~ ^[0-9]+$ ]]; then echo -e "${RED}$(tr_text ERR_NUM)${NC}"; continue; fi
        selected=$(sed -n "${choice}p" /tmp/matches_list.txt | cut -d' ' -f2-)
        [ -z "$selected" ] && { echo -e "${RED}$(tr_text ERR_NOT_FOUND)${NC}"; continue; }
        echo -e "${YELLOW}$(tr_text YOU_SELECTED)${NC} $selected"; return
    done
}

# ====== ОБНОВЛЕНИЕ ======
check_update() {
    local latest; latest=$(curl -s https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main/version.txt)
    [ -z "$latest" ] && { echo -e "${RED}$(tr_text UPDATE_FAIL)${NC}"; return; }
    VERSION=$(<"$SCRIPT_DIR/version.txt" 2>/dev/null || echo "dev")
    echo "$(tr_text CHECK_CURR) $VERSION"; echo "$(tr_text CHECK_LATEST) $latest"
    if [ "$VERSION" != "$latest" ]; then
        echo -e "${YELLOW}$(tr_text UPDATE_AVAIL)${NC}"; read -r ans
        if [[ "$ans" =~ ^[YyДд]$ ]]; then
            curl -s -o "$SCRIPT_DIR/scripts.sh" "$REPO_URL/scripts.sh"
            curl -s -o "$SCRIPT_DIR/version.txt" "$REPO_URL/version.txt"
            chmod +x "$SCRIPT_DIR/scripts.sh"
            echo -e "${GREEN}$(tr_text UPDATE_DONE) $latest${NC}"
            echo -e "${YELLOW}$(tr_text UPDATE_RESTART)${NC}"
            exec "$SCRIPT_DIR/scripts.sh"
        fi
    else
        echo -e "${GREEN}$(tr_text NO_UPDATES)${NC}"
    fi
}

# ====== УДАЛЕНИЕ ======
delete_self() { "$SCRIPT_DIR/uninstall.sh"; exit 0; }

# ====== МЕНЮ ======
show_menu() {
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

# ====== ЦИКЛ ======
while true; do show_menu; done