#!/bin/bash
# ====== НАСТРОЙКИ И ПОДГОТОВКА ======
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/remnawave"
CONFIG_DIR="$HOME/.config/remnawave"
SCRIPT_PATH="$HOME/.local/bin/rw-scripts"
REPO_URL="https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main"
PORTS_FILE="$DATA_DIR/ports.json"

# читаем версию
if [ -s "$DATA_DIR/version.txt" ]; then
    VERSION=$(tr -d '\r\n' < "$DATA_DIR/version.txt")
else
    VERSION="dev"
fi

# Цвета
RED='\e[31m'; YELLOW='\e[33m'; GREEN='\e[32m'; BLUE='\e[34m'; CYAN='\e[36m'; MAGENTA='\e[35m'; NC='\e[0m'
BOLD='\e[1m'; DIM='\e[2m'

# ====== БАННЕР ======
show_banner() {
    clear
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
        echo -e "   Go to [4] Maintenance → [1] Update to install.${NC}"
        echo
    fi
}

# ====== БРЭЙЛ-КРУТИЛКА ======
loading_bar() {
    local delay=0.15
    local spin=(⠋ ⠙ ⠸ ⠴ ⠦ ⠧ ⠇ ⠏)
    tput civis
    while :; do
        for frame in "${spin[@]}"; do
            printf "\r[%s] Пожалуйста, подождите " "$frame"
            sleep $delay
        done
    done
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
                # === ГЛАВНОЕ МЕНЮ - ГРУППЫ ===
                MAIN_TITLE)       echo "🏠 Главное меню" ;;
                GROUP_ID_FLAGS)   echo "🆔 Short ID & Флаги стран" ;;
                GROUP_MONITOR)    echo "📊 Монитор ресурсов" ;;
                GROUP_PORTS)      echo "🔐 Сеть и порты" ;;
                GROUP_SETTINGS)   echo "⚙️  Обслуживание" ;;
                
                # === ПОДМЕНЮ: Short ID & Flags ===
                SUB_GEN_IDS)      echo "🎲 Сгенерировать shorts_id" ;;
                SUB_FLAG)         echo "🏳️  Получить emoji-флаг страны" ;;
                
                # === ПОДМЕНЮ: Resource Monitor ===
                SUB_MEMORY)       echo "💾 Показать свободную память" ;;
                SUB_HTOP)         echo "📈 Запустить htop" ;;
                SUB_SYSINFO)      echo "🖥️  Системная информация" ;;
                
                # === ПОДМЕНЮ: Network & Ports ===
                SUB_PORTS)        echo "🔒 Управление портами" ;;
                
                # === ПОДМЕНЮ: Maintenance ===
                SUB_UPDATE)       echo "🔄 Проверить обновления" ;;
                SUB_DELETE)       echo "🗑️  Удалить rw-scripts" ;;
                
                # === НАВИГАЦИЯ ===
                MENU_BACK)        echo "⬅️  Назад" ;;
                MENU_EXIT)        echo "🚪 Выйти" ;;
                PROMPT_CHOICE)    echo "Выберите пункт:" ;;
                PROMPT_GROUP)     echo "Выберите группу:" ;;
                
                # === СООБЩЕНИЯ ===
                MSG_EXIT)         echo "Выход... Пока 👋" ;;
                MSG_BACK)         echo "Возврат в главное меню..." ;;
                ERR_CHOICE)       echo "Неверный выбор, попробуй ещё раз 😅" ;;
                IDS_HOW_MANY)     echo "Сколько идентификаторов сгенерировать?" ;;
                ERR_NUMBER)       echo "Ошибка: введите корректное число!" ;;
                ERR_GT_ZERO)      echo "Ошибка: количество должно быть больше нуля!" ;;
                IDS_DONE)         echo "ID сгенерированы! Вот твой список:" ;;
                ERR_IDS)          echo "Произошла ошибка во время генерации." ;;
                COUNTRY_PROMPT)   echo "Введите название страны (на русском или английском, можно часть, 0 = выход):" ;;
                NOTHING_FOUND)    echo "Ничего не найдено по запросу" ;;
                RESULTS)          echo "Результаты поиска:" ;;
                PROMPT_NUM)       echo "Выберите номер (или 0 для нового поиска):" ;;
                ERR_NUM)          echo "Введите корректный номер!" ;;
                ERR_NOT_FOUND)    echo "Нет варианта с таким номером." ;;
                YOU_SELECTED)     echo "Вы выбрали:" ;;
                CHECK_CURR)       echo "Текущая версия:" ;;
                CHECK_LATEST)     echo "Последняя версия:" ;;
                UPDATE_AVAIL)     echo "Есть новая версия! Хотите обновиться? (y/n)" ;;
                UPDATE_DONE)      echo "Скрипт обновлён до версии" ;;
                UPDATE_RESTART)   echo "Перезапуск..." ;;
                UPDATE_FAIL)      echo "Не удалось проверить обновления." ;;
                NO_UPDATES)       echo "У вас уже последняя версия." ;;
                CONFIRM_DEL)      echo "Вы уверены, что хотите удалить rw-scripts? (y/n)" ;;
                CANCEL_DEL)       echo "Отменено" ;;
                PRESS_ENTER)      echo "Нажмите Enter для продолжения..." ;;
            esac ;;
        "en" | *)
            case "$1" in
                # === MAIN MENU - GROUPS ===
                MAIN_TITLE)       echo "🏠 Main Menu" ;;
                GROUP_ID_FLAGS)   echo "🆔 Short ID & Country Flags" ;;
                GROUP_MONITOR)    echo "📊 Resource Monitor" ;;
                GROUP_PORTS)      echo "🔐 Network & Ports" ;;
                GROUP_SETTINGS)   echo "⚙️  Maintenance" ;;
                
                # === SUBMENU: Short ID & Flags ===
                SUB_GEN_IDS)      echo "🎲 Generate shorts_id" ;;
                SUB_FLAG)         echo "🏳️  Get country emoji flag" ;;
                
                # === SUBMENU: Resource Monitor ===
                SUB_MEMORY)       echo "💾 Show free memory" ;;
                SUB_HTOP)         echo "📈 Launch htop" ;;
                SUB_SYSINFO)      echo "🖥️  System information" ;;
                
                # === SUBMENU: Network & Ports ===
                SUB_PORTS)        echo "🔒 Port management" ;;
                
                # === SUBMENU: Maintenance ===
                SUB_UPDATE)       echo "🔄 Check for updates" ;;
                SUB_DELETE)       echo "🗑️  Uninstall rw-scripts" ;;
                
                # === NAVIGATION ===
                MENU_BACK)        echo "⬅️  Back" ;;
                MENU_EXIT)        echo "🚪 Exit" ;;
                PROMPT_CHOICE)    echo "Choose an option:" ;;
                PROMPT_GROUP)     echo "Choose a group:" ;;
                
                # === MESSAGES ===
                MSG_EXIT)         echo "Exiting... Bye 👋" ;;
                MSG_BACK)         echo "Returning to main menu..." ;;
                ERR_CHOICE)       echo "Invalid choice, try again 😅" ;;
                IDS_HOW_MANY)     echo "How many IDs to generate?" ;;
                ERR_NUMBER)       echo "Error: enter a valid number!" ;;
                ERR_GT_ZERO)      echo "Error: number must be greater than zero!" ;;
                IDS_DONE)         echo "IDs generated! Here is your list:" ;;
                ERR_IDS)          echo "An error occurred during generation." ;;
                COUNTRY_PROMPT)   echo "Enter country name (English or Russian, part allowed, 0 = exit):" ;;
                NOTHING_FOUND)    echo "Nothing found for query" ;;
                RESULTS)          echo "Search results:" ;;
                PROMPT_NUM)       echo "Choose number (or 0 for new search):" ;;
                ERR_NUM)          echo "Enter a valid number!" ;;
                ERR_NOT_FOUND)    echo "No option with that number found." ;;
                YOU_SELECTED)     echo "You selected:" ;;
                CHECK_CURR)       echo "Current version:" ;;
                CHECK_LATEST)     echo "Latest version:" ;;
                UPDATE_AVAIL)     echo "New version available! Update? (y/n)" ;;
                UPDATE_DONE)      echo "Script updated to version" ;;
                UPDATE_RESTART)   echo "Restarting..." ;;
                UPDATE_FAIL)      echo "Failed to check for updates." ;;
                NO_UPDATES)       echo "You already have the latest version." ;;
                CONFIRM_DEL)      echo "Are you sure you want to uninstall rw-scripts? (y/n)" ;;
                CANCEL_DEL)       echo "Canceled" ;;
                PRESS_ENTER)      echo "Press Enter to continue..." ;;
            esac ;;
    esac
}

# ====== ЗАГОЛОВОК ПОДМЕНЮ ======
print_submenu_header() {
    local title="$1"
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}${MAGENTA}$title${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo
}

# ====== ФУНКЦИЯ: СИСТЕМНАЯ ИНФА ======
show_system_info() {
    echo -e "${GREEN}======== 📊 System Information ========${NC}"

    if ! command -v neofetch >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Neofetch is not installed.${NC}"
        read -rp "👉 Install neofetch now? (y/n): " ans
        if [[ "$ans" =~ ^[YyДд]$ ]]; then
            echo -e "${BLUE}🔧 Installing neofetch...${NC}"
            loading_bar & pid=$!
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update &>/dev/null && sudo apt-get install -y neofetch &>/dev/null
            elif command -v apt >/dev/null 2>&1; then
                sudo apt update &>/dev/null && sudo apt install -y neofetch &>/dev/null
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y neofetch &>/dev/null
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y neofetch &>/dev/null
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -Sy --noconfirm neofetch &>/dev/null
            elif command -v zypper >/dev/null 2>&1; then
                sudo zypper install -y neofetch &>/dev/null
            elif command -v brew >/dev/null 2>&1; then
                brew install neofetch &>/dev/null
            else
                kill $pid >/dev/null 2>&1; tput cnorm
                echo -e "\r${RED}❌ Could not detect a package manager. Please install neofetch manually.${NC}          "
                return 1
            fi
            kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm
            echo -e "\r✅ Neofetch installed!                                                              "
        else
            echo -e "${RED}❌ Neofetch not installed. Skipping system info.${NC}"
            return 0
        fi
    fi

    if command -v neofetch >/dev/null 2>&1; then
        neofetch
    else
        echo -e "${RED}❌ Neofetch installation failed.${NC}"
    fi

    echo -e "${GREEN}========================================${NC}"
}

# ====== ПОКАЗАТЬ СВОБОДНУЮ ПАМЯТЬ ======
show_memory() {
    echo -e "${GREEN}======== 💾 Memory Information ========${NC}"
    
    if command -v free >/dev/null 2>&1; then
        free -h
    else
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "${BLUE}Memory stats (macOS):${NC}"
            vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("%-16s % 16.2f MB\n", "$1:", $2 * $size / 1048576);'
        else
            echo -e "${YELLOW}⚠️  'free' command not found. Trying alternative...${NC}"
            if [ -f /proc/meminfo ]; then
                awk '/MemTotal|MemFree|MemAvailable|Buffers|Cached/ {printf "%-20s: %10s kB\n", $1, $2}' /proc/meminfo
            else
                echo -e "${RED}❌ Cannot determine memory information on this system.${NC}"
            fi
        fi
    fi
    
    echo -e "${GREEN}========================================${NC}"
}

# ====== ЗАПУСК HTOP ======
launch_htop() {
    if ! command -v htop >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  htop is not installed.${NC}"
        read -rp "👉 Install htop now? (y/n): " ans
        if [[ "$ans" =~ ^[YyДд]$ ]]; then
            echo -e "${BLUE}🔧 Installing htop...${NC}"
            loading_bar & pid=$!
            
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update &>/dev/null && sudo apt-get install -y htop &>/dev/null
            elif command -v apt >/dev/null 2>&1; then
                sudo apt update &>/dev/null && sudo apt install -y htop &>/dev/null
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y htop &>/dev/null
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y htop &>/dev/null
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -Sy --noconfirm htop &>/dev/null
            elif command -v zypper >/dev/null 2>&1; then
                sudo zypper install -y htop &>/dev/null
            elif command -v brew >/dev/null 2>&1; then
                brew install htop &>/dev/null
            else
                kill $pid >/dev/null 2>&1; tput cnorm
                echo -e "\r${RED}❌ Could not detect a package manager. Please install htop manually.${NC}          "
                return 1
            fi
            
            kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm
            echo -e "\r✅ htop installed!                                                              "
        else
            echo -e "${RED}❌ htop not installed. Returning to menu.${NC}"
            return 0
        fi
    fi

    if command -v htop >/dev/null 2>&1; then
        echo -e "${GREEN}🚀 Launching htop... (Press 'q' or F10 to exit)${NC}"
        sleep 1
        htop
    else
        echo -e "${RED}❌ htop installation failed.${NC}"
    fi
}

# ====== УПРАВЛЕНИЕ ПОРТАМИ ======

detect_firewall() {
    if command -v ufw >/dev/null 2>&1; then
        echo "ufw"
    elif command -v firewall-cmd >/dev/null 2>&1; then
        echo "firewalld"
    elif command -v iptables >/dev/null 2>&1; then
        echo "iptables"
    else
        echo "none"
    fi
}

init_ports_file() {
    if [ ! -f "$PORTS_FILE" ]; then
        echo "[]" > "$PORTS_FILE"
    fi
}

ensure_jq() {
    if command -v jq >/dev/null 2>&1; then
        return 0
    fi
    
    echo -e "${YELLOW}⚙️  'jq' не установлен. Устанавливаю...${NC}"
    loading_bar & pid=$!
    
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -qq &>/dev/null && sudo apt-get install -y jq &>/dev/null
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update -qq &>/dev/null && sudo apt install -y jq &>/dev/null
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y jq &>/dev/null
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y jq &>/dev/null
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm jq &>/dev/null
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y jq &>/dev/null
    elif command -v brew >/dev/null 2>&1; then
        brew install jq &>/dev/null
    else
        kill $pid >/dev/null 2>&1; tput cnorm
        echo -e "\r${RED}❌ Не удалось определить пакетный менеджер.${NC}"
        return 1
    fi
    
    kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm
    
    if command -v jq >/dev/null 2>&1; then
        echo -e "\r✅ jq успешно установлен!                    "
        return 0
    else
        echo -e "\r${RED}❌ Не удалось установить jq.${NC}"
        return 1
    fi
}

add_port_to_json() {
    local port=$1 protocol=$2 description=$3
    local timestamp=$(date +%s)
    
    init_ports_file
    ensure_jq || return 1
    
    local temp_file=$(mktemp)
    jq ". += [{\"port\": \"$port\", \"protocol\": \"$protocol\", \"description\": \"$description\", \"timestamp\": $timestamp}]" "$PORTS_FILE" > "$temp_file"
    mv "$temp_file" "$PORTS_FILE"
}

remove_port_from_json() {
    local port=$1 protocol=$2
    ensure_jq || return 1
    
    local temp_file=$(mktemp)
    jq "map(select(.port != \"$port\" or .protocol != \"$protocol\"))" "$PORTS_FILE" > "$temp_file"
    mv "$temp_file" "$PORTS_FILE"
}

edit_port_description() {
    local port=$1 protocol=$2 new_description=$3
    ensure_jq || return 1
    
    local temp_file=$(mktemp)
    jq "map(if .port == \"$port\" and .protocol == \"$protocol\" then .description = \"$new_description\" else . end)" "$PORTS_FILE" > "$temp_file"
    mv "$temp_file" "$PORTS_FILE"
}

open_port() {
    local firewall=$(detect_firewall)
    
    if [ "$firewall" = "none" ]; then
        echo -e "${RED}❌ Firewall не обнаружен.${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     🔓 Открыть порт / Open Port      ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo
    read -rp "Введите номер порта (1-65535): " port
    
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}❌ Неверный номер порта${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    echo
    echo "Выберите протокол:"
    echo -e "${YELLOW}1)${NC} TCP"
    echo -e "${YELLOW}2)${NC} UDP"
    echo -e "${YELLOW}3)${NC} TCP и UDP"
    read -rp "> " proto_choice
    
    case $proto_choice in
        1) protocol="tcp" ;;
        2) protocol="udp" ;;
        3) protocol="both" ;;
        *) echo -e "${RED}❌ Неверный выбор${NC}"; return 1 ;;
    esac
    
    read -rp "Описание порта: " description
    [ -z "$description" ] && description="No description"
    
    echo -e "${BLUE}⏳ Открываю порт $port ($protocol)...${NC}"
    
    case $firewall in
        ufw)
            if [ "$protocol" = "both" ]; then
                sudo ufw allow "$port"/tcp &>/dev/null
                sudo ufw allow "$port"/udp &>/dev/null
                add_port_to_json "$port" "tcp" "$description"
                add_port_to_json "$port" "udp" "$description"
            else
                sudo ufw allow "$port"/"$protocol" &>/dev/null
                add_port_to_json "$port" "$protocol" "$description"
            fi
            ;;
        firewalld)
            if [ "$protocol" = "both" ]; then
                sudo firewall-cmd --permanent --add-port="$port"/tcp &>/dev/null
                sudo firewall-cmd --permanent --add-port="$port"/udp &>/dev/null
                add_port_to_json "$port" "tcp" "$description"
                add_port_to_json "$port" "udp" "$description"
            else
                sudo firewall-cmd --permanent --add-port="$port"/"$protocol" &>/dev/null
                add_port_to_json "$port" "$protocol" "$description"
            fi
            sudo firewall-cmd --reload &>/dev/null
            ;;
        iptables)
            if [ "$protocol" = "both" ]; then
                sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
                sudo iptables -A INPUT -p udp --dport "$port" -j ACCEPT
                add_port_to_json "$port" "tcp" "$description"
                add_port_to_json "$port" "udp" "$description"
            else
                sudo iptables -A INPUT -p "$protocol" --dport "$port" -j ACCEPT
                add_port_to_json "$port" "$protocol" "$description"
            fi
            command -v netfilter-persistent &>/dev/null && sudo netfilter-persistent save &>/dev/null
            ;;
    esac
    
    echo -e "${GREEN}✅ Порт $port ($protocol) открыт!${NC}"
    read -rp "$(tr_text PRESS_ENTER)"
}

close_port() {
    local firewall=$(detect_firewall)
    
    if [ "$firewall" = "none" ]; then
        echo -e "${RED}❌ Firewall не обнаружен.${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    list_ports
    
    if [ ! -s "$PORTS_FILE" ] || [ "$(cat "$PORTS_FILE")" = "[]" ]; then
        echo -e "${YELLOW}Нет открытых портов.${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi
    
    echo
    read -rp "Введите номер порта: " port
    
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ Неверный номер порта${NC}"
        return 1
    fi
    
    echo "Протокол: 1) TCP  2) UDP  3) Оба"
    read -rp "> " proto_choice
    
    case $proto_choice in
        1) protocol="tcp" ;;
        2) protocol="udp" ;;
        3) protocol="both" ;;
        *) return 1 ;;
    esac
    
    case $firewall in
        ufw)
            if [ "$protocol" = "both" ]; then
                sudo ufw delete allow "$port"/tcp &>/dev/null
                sudo ufw delete allow "$port"/udp &>/dev/null
                remove_port_from_json "$port" "tcp"
                remove_port_from_json "$port" "udp"
            else
                sudo ufw delete allow "$port"/"$protocol" &>/dev/null
                remove_port_from_json "$port" "$protocol"
            fi
            ;;
        firewalld)
            if [ "$protocol" = "both" ]; then
                sudo firewall-cmd --permanent --remove-port="$port"/tcp &>/dev/null
                sudo firewall-cmd --permanent --remove-port="$port"/udp &>/dev/null
                remove_port_from_json "$port" "tcp"
                remove_port_from_json "$port" "udp"
            else
                sudo firewall-cmd --permanent --remove-port="$port"/"$protocol" &>/dev/null
                remove_port_from_json "$port" "$protocol"
            fi
            sudo firewall-cmd --reload &>/dev/null
            ;;
        iptables)
            if [ "$protocol" = "both" ]; then
                sudo iptables -D INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null
                sudo iptables -D INPUT -p udp --dport "$port" -j ACCEPT 2>/dev/null
                remove_port_from_json "$port" "tcp"
                remove_port_from_json "$port" "udp"
            else
                sudo iptables -D INPUT -p "$protocol" --dport "$port" -j ACCEPT 2>/dev/null
                remove_port_from_json "$port" "$protocol"
            fi
            ;;
    esac
    
    echo -e "${GREEN}✅ Порт $port закрыт!${NC}"
    read -rp "$(tr_text PRESS_ENTER)"
}

edit_port() {
    list_ports
    
    if [ ! -s "$PORTS_FILE" ] || [ "$(cat "$PORTS_FILE")" = "[]" ]; then
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi
    
    echo
    read -rp "Номер порта: " port
    echo "Протокол: 1) TCP  2) UDP"
    read -rp "> " proto_choice
    
    case $proto_choice in
        1) protocol="tcp" ;;
        2) protocol="udp" ;;
        *) return 1 ;;
    esac
    
    ensure_jq || return 1
    local exists=$(jq -r ".[] | select(.port == \"$port\" and .protocol == \"$protocol\") | .description" "$PORTS_FILE")
    
    if [ -z "$exists" ]; then
        echo -e "${RED}❌ Порт не найден.${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    echo -e "${BLUE}Текущее описание:${NC} $exists"
    read -rp "Новое описание: " new_description
    
    [ -n "$new_description" ] && edit_port_description "$port" "$protocol" "$new_description"
    echo -e "${GREEN}✅ Обновлено!${NC}"
    read -rp "$(tr_text PRESS_ENTER)"
}

list_ports() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           📋 Открытые порты / Open Ports                 ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    
    init_ports_file
    
    if [ ! -s "$PORTS_FILE" ] || [ "$(cat "$PORTS_FILE")" = "[]" ]; then
        echo -e "${YELLOW}📭 Нет сохраненных портов${NC}"
        return
    fi
    
    ensure_jq || return 1
    
    echo
    echo -e "${BLUE}┌─────────┬───────────┬──────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${MAGENTA}Port${NC}    ${BLUE}│${NC} ${MAGENTA}Protocol${NC}  ${BLUE}│${NC} ${MAGENTA}Description${NC}                          ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────┼───────────┼──────────────────────────────────────┤${NC}"
    
    jq -r '.[] | "\(.port)|\(.protocol)|\(.description)"' "$PORTS_FILE" | while IFS='|' read -r port proto desc; do
        [ ${#desc} -gt 36 ] && desc="${desc:0:33}..."
        printf "${BLUE}│${NC} ${GREEN}%-7s${NC} ${BLUE}│${NC} ${YELLOW}%-9s${NC} ${BLUE}│${NC} %-36s ${BLUE}│${NC}\n" "$port" "$proto" "$desc"
    done
    
    echo -e "${BLUE}└─────────┴───────────┴──────────────────────────────────────┘${NC}"
    
    local total=$(jq '. | length' "$PORTS_FILE")
    echo -e "${CYAN}📊 Всего: $total${NC}"
}

show_firewall_status() {
    local firewall=$(detect_firewall)
    
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    🛡️  Статус Firewall              ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo
    
    case $firewall in
        ufw)
            echo -e "${GREEN}Firewall: UFW${NC}"
            sudo ufw status verbose
            ;;
        firewalld)
            echo -e "${GREEN}Firewall: FirewallD${NC}"
            sudo firewall-cmd --state
            sudo firewall-cmd --list-all
            ;;
        iptables)
            echo -e "${GREEN}Firewall: iptables${NC}"
            sudo iptables -L -n -v --line-numbers
            ;;
        none)
            echo -e "${RED}❌ Firewall не обнаружен${NC}"
            ;;
    esac
    
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# Подменю управления портами
port_management() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text SUB_PORTS)"
        
        echo -e "  ${YELLOW}1)${NC} 🔓 Открыть порт"
        echo -e "  ${YELLOW}2)${NC} 🔒 Закрыть порт"
        echo -e "  ${YELLOW}3)${NC} ✏️  Редактировать описание"
        echo -e "  ${YELLOW}4)${NC} 📋 Список портов"
        echo -e "  ${YELLOW}5)${NC} 🛡️  Статус firewall"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        
        case $choice in
            1) show_banner; open_port ;;
            2) show_banner; close_port ;;
            3) show_banner; edit_port ;;
            4) show_banner; list_ports; echo; read -rp "$(tr_text PRESS_ENTER)" ;;
            5) show_banner; show_firewall_status ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ====== ГЕНЕРАЦИЯ ID ======
ensure_xxd() {
    if command -v xxd >/dev/null 2>&1; then return 0; fi
    echo -e "${YELLOW}⚙️  Устанавливаю 'xxd'...${NC}"

    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -qq && (sudo apt-get install -y vim-xxd || sudo apt-get install -y xxd)
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update -qq && (sudo apt install -y vim-xxd || sudo apt install -y xxd)
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y vim-xxd
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y vim-xxd
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm vim-xxd
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y vim-xxd
    elif command -v brew >/dev/null 2>&1; then
        brew install xxd
    else
        echo -e "${RED}❌ Не удалось установить xxd.${NC}"
        return 1
    fi

    command -v xxd >/dev/null 2>&1 && echo -e "${GREEN}✅ xxd установлен!${NC}" || return 1
}

generate_ids() {
    ensure_xxd || return
    echo -ne "${BLUE}$(tr_text IDS_HOW_MANY)${NC} "
    read -r count
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}$(tr_text ERR_NUMBER)${NC}"; return
    fi
    if [ "$count" -le 0 ]; then
        echo -e "${RED}$(tr_text ERR_GT_ZERO)${NC}"; return
    fi
    echo -e "${GREEN}$(tr_text IDS_DONE)${NC}\n"
    for ((i=1; i<=count; i++)); do
        id=$(head -c 8 /dev/urandom | xxd -p)
        echo "\"$id\","
    done
    echo
    read -rp "$(tr_text PRESS_ENTER)"
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
    [ "$input" = "0" ] && return
    key=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    COUNTRIES_FILE="$DATA_DIR/countries.csv"
    if [ ! -f "$COUNTRIES_FILE" ]; then
        echo -e "${RED}countries.csv not found${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return
    fi
    matches=$(awk -F',' -v key="$key" '
    { ru=tolower($1); en=tolower($2); iso=$3;
      if (ru ~ key || en ~ key) { print iso "," $2; }
    }' "$COUNTRIES_FILE")
    if [ -z "$matches" ]; then
        echo -e "${RED}$(tr_text NOTHING_FOUND) '${input}'.${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return
    fi
    total=$(echo "$matches" | wc -l)
    if [ "$total" -gt 10 ]; then
        echo -e "${YELLOW}Найдено ${total}. Показать все? (y/n)${NC}"
        read ans
        [[ ! "$ans" =~ ^[YyДд]$ ]] && return
    fi
    echo -e "${GREEN}$(tr_text RESULTS)${NC}"
    echo "$matches" | while IFS=',' read -r iso en; do
        flag=$(iso_to_flag "$iso")
        echo " $flag $en"
    done
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

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
    
    local tmp_script="$SCRIPT_PATH.tmp"
    local tmp_version="$DATA_DIR/version.txt.tmp"

    echo -e "${BLUE}⏳ Downloading...${NC}"
    loading_bar & pid=$!
    
    if ! curl -fsSL -o "$tmp_script" "$REPO_URL/scripts.sh" || \
       ! curl -fsSL -o "$tmp_version" "$REPO_URL/version.txt"; then
        kill $pid >/dev/null 2>&1; tput cnorm
        echo -e "\r${RED}$(tr_text UPDATE_FAIL)${NC}          "
        rm -f "$tmp_script" "$tmp_version"
        return 1
    fi
    
    kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm
    
    mv "$tmp_script" "$SCRIPT_PATH"; chmod +x "$SCRIPT_PATH"
    mv "$tmp_version" "$DATA_DIR/version.txt"
    
    echo -e "\r${GREEN}$(tr_text UPDATE_DONE) $latest${NC}     "
    echo -e "${YELLOW}$(tr_text UPDATE_RESTART)${NC}"
    exec "$SCRIPT_PATH"
}

# ====== УДАЛЕНИЕ ======
delete_self() {
    echo -e "${RED}$(tr_text CONFIRM_DEL)${NC}"
    read -r ans
    [[ "$ans" =~ ^[YyДд]$ ]] && { "$DATA_DIR/uninstall.sh"; exit 0; }
    echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
}

# ══════════════════════════════════════════════════════════════════
#                        ПОДМЕНЮ ГРУПП
# ══════════════════════════════════════════════════════════════════

# ====== ПОДМЕНЮ 1: Short ID & Flags ======
submenu_id_flags() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_ID_FLAGS)"
        
        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_GEN_IDS)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_FLAG)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        
        case $choice in
            1) show_banner; generate_ids ;;
            2) show_banner; country_lookup ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ====== ПОДМЕНЮ 2: Resource Monitor ======
submenu_monitor() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_MONITOR)"
        
        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_MEMORY)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_HTOP)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text SUB_SYSINFO)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        
        case $choice in
            1) show_banner; show_memory; echo; read -rp "$(tr_text PRESS_ENTER)" ;;
            2) show_banner; launch_htop ;;
            3) show_banner; show_system_info; echo; read -rp "$(tr_text PRESS_ENTER)" ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ====== ПОДМЕНЮ 3: Network & Ports ======
submenu_network() {
    port_management
}

# ====== ПОДМЕНЮ 4: Maintenance ======
submenu_maintenance() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_SETTINGS)"
        
        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_UPDATE)"
        echo -e "  ${RED}2)${NC} $(tr_text SUB_DELETE)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        
        case $choice in
            1) show_banner; check_update ;;
            2) show_banner; delete_self ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ══════════════════════════════════════════════════════════════════
#                        ГЛАВНОЕ МЕНЮ
# ══════════════════════════════════════════════════════════════════

show_main_menu() {
    while true; do
        show_banner
        auto_check_update
        
        echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}           ${BOLD}$(tr_text MAIN_TITLE)${NC}                   ${CYAN}║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
        echo
        echo -e "  ${YELLOW}1)${NC} $(tr_text GROUP_ID_FLAGS)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text GROUP_MONITOR)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text GROUP_PORTS)"
        echo -e "  ${YELLOW}4)${NC} $(tr_text GROUP_SETTINGS)"
        echo
        echo -e "  ${DIM}─────────────────────────────────────────${NC}"
        echo -e "  ${YELLOW}0)${NC} $(tr_text MENU_EXIT)"
        echo
        echo -e "${BLUE}$(tr_text PROMPT_GROUP)${NC}"
        read -rp "> " choice
        
        case $choice in
            1) submenu_id_flags ;;
            2) submenu_monitor ;;
            3) submenu_network ;;
            4) submenu_maintenance ;;
            0) echo -e "${GREEN}$(tr_text MSG_EXIT)${NC}"; exit 0 ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ====== ЗАПУСК ======
show_main_menu