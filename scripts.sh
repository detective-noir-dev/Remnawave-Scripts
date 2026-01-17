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
                MENU_GEN_IDS) echo "1) Сгенерировать shorts_id" ;;
                MENU_FLAG)    echo "2) Получить emoji-флаг страны" ;;
                MENU_UPDATE)  echo "3) Проверить версию/обновить" ;;
                MENU_DELETE)  echo "4) Удалить rw-scripts" ;;
                MENU_MEMORY)  echo "5) Показать свободную память" ;;
                MENU_HTOP)    echo "6) Запустить htop (монитор процессов)" ;;
                MENU_SYSINFO) echo "7) Показать системную информацию" ;;
                MENU_PORTS)   echo "8) Управление портами 🔒" ;;
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
                MENU_MEMORY)  echo "5) Show free memory" ;;
                MENU_HTOP)    echo "6) Launch htop (process monitor)" ;;
                MENU_SYSINFO) echo "7) Show system info" ;;
                MENU_PORTS)   echo "8) Port management 🔒" ;;
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

# Определяем firewall в системе
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

# Инициализация файла портов
init_ports_file() {
    if [ ! -f "$PORTS_FILE" ]; then
        echo "[]" > "$PORTS_FILE"
    fi
}

# Проверка установки jq
ensure_jq() {
    if command -v jq >/dev/null 2>&1; then
        return 0
    fi
    
    echo -e "${YELLOW}⚙️  'jq' не установлен. Устанавливаю для работы с портами...${NC}"
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
        echo -e "\r${RED}❌ Не удалось определить пакетный менеджер. Установите 'jq' вручную.${NC}"
        return 1
    fi
    
    kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm
    
    if command -v jq >/dev/null 2>&1; then
        echo -e "\r✅ jq успешно установлен!                                                    "
        return 0
    else
        echo -e "\r${RED}❌ Не удалось установить jq.${NC}"
        return 1
    fi
}

# Добавить порт в JSON
add_port_to_json() {
    local port=$1
    local protocol=$2
    local description=$3
    local timestamp=$(date +%s)
    
    init_ports_file
    ensure_jq || return 1
    
    local temp_file=$(mktemp)
    jq ". += [{\"port\": \"$port\", \"protocol\": \"$protocol\", \"description\": \"$description\", \"timestamp\": $timestamp}]" "$PORTS_FILE" > "$temp_file"
    mv "$temp_file" "$PORTS_FILE"
}

# Удалить порт из JSON
remove_port_from_json() {
    local port=$1
    local protocol=$2
    
    ensure_jq || return 1
    
    local temp_file=$(mktemp)
    jq "map(select(.port != \"$port\" or .protocol != \"$protocol\"))" "$PORTS_FILE" > "$temp_file"
    mv "$temp_file" "$PORTS_FILE"
}

# Редактировать описание порта
edit_port_description() {
    local port=$1
    local protocol=$2
    local new_description=$3
    
    ensure_jq || return 1
    
    local temp_file=$(mktemp)
    jq "map(if .port == \"$port\" and .protocol == \"$protocol\" then .description = \"$new_description\" else . end)" "$PORTS_FILE" > "$temp_file"
    mv "$temp_file" "$PORTS_FILE"
}

# Открыть порт
open_port() {
    local firewall=$(detect_firewall)
    
    if [ "$firewall" = "none" ]; then
        echo -e "${RED}❌ Firewall не обнаружен. Установите ufw, firewalld или iptables.${NC}"
        echo -e "${YELLOW}💡 Для Ubuntu/Debian: sudo apt install ufw${NC}"
        echo -e "${YELLOW}💡 Для RHEL/CentOS: sudo yum install firewalld${NC}"
        read -rp "Нажмите Enter для возврата в меню..."
        return 1
    fi
    
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     🔓 Открыть порт / Open Port      ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo
    read -rp "Введите номер порта (1-65535): " port
    
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}❌ Неверный номер порта (допустимо: 1-65535)${NC}"
        read -rp "Нажмите Enter для возврата..."
        return 1
    fi
    
    echo
    echo "Выберите протокол:"
    echo -e "${YELLOW}1)${NC} TCP"
    echo -e "${YELLOW}2)${NC} UDP"
    echo -e "${YELLOW}3)${NC} TCP и UDP (оба)"
    echo
    read -rp "> " proto_choice
    
    case $proto_choice in
        1) protocol="tcp" ;;
        2) protocol="udp" ;;
        3) protocol="both" ;;
        *) echo -e "${RED}❌ Неверный выбор${NC}"; read -rp "Нажмите Enter..."; return 1 ;;
    esac
    
    echo
    read -rp "Описание порта (например: 'SSH server', 'Web server'): " description
    [ -z "$description" ] && description="No description"
    
    echo
    echo -e "${BLUE}⏳ Открываю порт $port ($protocol)...${NC}"
    
    # Открываем порт в firewall
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
                sudo firewall-cmd --reload &>/dev/null
                add_port_to_json "$port" "tcp" "$description"
                add_port_to_json "$port" "udp" "$description"
            else
                sudo firewall-cmd --permanent --add-port="$port"/"$protocol" &>/dev/null
                sudo firewall-cmd --reload &>/dev/null
                add_port_to_json "$port" "$protocol" "$description"
            fi
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
            # Сохраняем правила
            if command -v netfilter-persistent >/dev/null 2>&1; then
                sudo netfilter-persistent save &>/dev/null
            elif command -v iptables-save >/dev/null 2>&1; then
                sudo iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
            fi
            ;;
    esac
    
    echo -e "${GREEN}✅ Порт $port ($protocol) успешно открыт!${NC}"
    echo -e "${GREEN}📝 Описание: $description${NC}"
    echo
    read -rp "Нажмите Enter для продолжения..."
}

# Закрыть порт
close_port() {
    local firewall=$(detect_firewall)
    
    if [ "$firewall" = "none" ]; then
        echo -e "${RED}❌ Firewall не обнаружен.${NC}"
        read -rp "Нажмите Enter для возврата..."
        return 1
    fi
    
    list_ports
    echo
    
    if [ ! -s "$PORTS_FILE" ] || [ "$(cat "$PORTS_FILE")" = "[]" ]; then
        echo -e "${YELLOW}Нет открытых портов для закрытия.${NC}"
        read -rp "Нажмите Enter для возврата..."
        return 0
    fi
    
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     🔒 Закрыть порт / Close Port     ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo
    read -rp "Введите номер порта для закрытия: " port
    
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ Неверный номер порта${NC}"
        read -rp "Нажмите Enter..."
        return 1
    fi
    
    echo
    echo "Выберите протокол:"
    echo -e "${YELLOW}1)${NC} TCP"
    echo -e "${YELLOW}2)${NC} UDP"
    echo -e "${YELLOW}3)${NC} Оба (TCP и UDP)"
    echo
    read -rp "> " proto_choice
    
    case $proto_choice in
        1) protocol="tcp" ;;
        2) protocol="udp" ;;
        3) protocol="both" ;;
        *) echo -e "${RED}❌ Неверный выбор${NC}"; read -rp "Нажмите Enter..."; return 1 ;;
    esac
    
    echo
    echo -e "${BLUE}⏳ Закрываю порт $port ($protocol)...${NC}"
    
    # Закрываем порт в firewall
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
                sudo firewall-cmd --reload &>/dev/null
                remove_port_from_json "$port" "tcp"
                remove_port_from_json "$port" "udp"
            else
                sudo firewall-cmd --permanent --remove-port="$port"/"$protocol" &>/dev/null
                sudo firewall-cmd --reload &>/dev/null
                remove_port_from_json "$port" "$protocol"
            fi
            ;;
        iptables)
            if [ "$protocol" = "both" ]; then
                sudo iptables -D INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null || true
                sudo iptables -D INPUT -p udp --dport "$port" -j ACCEPT 2>/dev/null || true
                remove_port_from_json "$port" "tcp"
                remove_port_from_json "$port" "udp"
            else
                sudo iptables -D INPUT -p "$protocol" --dport "$port" -j ACCEPT 2>/dev/null || true
                remove_port_from_json "$port" "$protocol"
            fi
            if command -v netfilter-persistent >/dev/null 2>&1; then
                sudo netfilter-persistent save &>/dev/null
            fi
            ;;
    esac
    
    echo -e "${GREEN}✅ Порт $port ($protocol) успешно закрыт!${NC}"
    echo
    read -rp "Нажмите Enter для продолжения..."
}

# Редактировать описание порта
edit_port() {
    list_ports
    echo
    
    if [ ! -s "$PORTS_FILE" ] || [ "$(cat "$PORTS_FILE")" = "[]" ]; then
        echo -e "${YELLOW}Нет портов для редактирования.${NC}"
        read -rp "Нажмите Enter для возврата..."
        return 0
    fi
    
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  ✏️  Редактировать описание порта    ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo
    read -rp "Введите номер порта: " port
    
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ Неверный номер порта${NC}"
        read -rp "Нажмите Enter..."
        return 1
    fi
    
    echo
    echo "Выберите протокол:"
    echo -e "${YELLOW}1)${NC} TCP"
    echo -e "${YELLOW}2)${NC} UDP"
    echo
    read -rp "> " proto_choice
    
    case $proto_choice in
        1) protocol="tcp" ;;
        2) protocol="udp" ;;
        *) echo -e "${RED}❌ Неверный выбор${NC}"; read -rp "Нажмите Enter..."; return 1 ;;
    esac
    
    # Проверяем, существует ли такой порт
    ensure_jq || return 1
    local exists=$(jq -r ".[] | select(.port == \"$port\" and .protocol == \"$protocol\") | .description" "$PORTS_FILE")
    
    if [ -z "$exists" ]; then
        echo -e "${RED}❌ Порт $port ($protocol) не найден в списке.${NC}"
        read -rp "Нажмите Enter..."
        return 1
    fi
    
    echo -e "${BLUE}Текущее описание:${NC} $exists"
    echo
    read -rp "Новое описание: " new_description
    
    if [ -z "$new_description" ]; then
        echo -e "${YELLOW}Описание не изменено.${NC}"
        read -rp "Нажмите Enter..."
        return 0
    fi
    
    edit_port_description "$port" "$protocol" "$new_description"
    echo -e "${GREEN}✅ Описание обновлено!${NC}"
    echo
    read -rp "Нажмите Enter для продолжения..."
}

# Список открытых портов
list_ports() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           📋 Открытые порты / Open Ports                 ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    
    init_ports_file
    
    if [ ! -s "$PORTS_FILE" ] || [ "$(cat "$PORTS_FILE")" = "[]" ]; then
        echo -e "${YELLOW}📭 Нет сохраненных портов / No saved ports${NC}"
        return
    fi
    
    ensure_jq || return 1
    
    echo
    echo -e "${BLUE}┌─────────┬───────────┬──────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${MAGENTA}Port${NC}    ${BLUE}│${NC} ${MAGENTA}Protocol${NC}  ${BLUE}│${NC} ${MAGENTA}Description${NC}                          ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────┼───────────┼──────────────────────────────────────┤${NC}"
    
    jq -r '.[] | "\(.port)|\(.protocol)|\(.description)"' "$PORTS_FILE" | while IFS='|' read -r port proto desc; do
        # Обрезаем описание если слишком длинное
        if [ ${#desc} -gt 36 ]; then
            desc="${desc:0:33}..."
        fi
        printf "${BLUE}│${NC} ${GREEN}%-7s${NC} ${BLUE}│${NC} ${YELLOW}%-9s${NC} ${BLUE}│${NC} %-36s ${BLUE}│${NC}\n" "$port" "$proto" "$desc"
    done
    
    echo -e "${BLUE}└─────────┴───────────┴──────────────────────────────────────┘${NC}"
    
    # Показываем общее количество
    local total=$(jq '. | length' "$PORTS_FILE")
    echo -e "${CYAN}📊 Всего открытых портов: $total${NC}"
}

# Показать статус firewall
show_firewall_status() {
    local firewall=$(detect_firewall)
    
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    🛡️  Статус Firewall / Status     ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo
    
    case $firewall in
        ufw)
            echo -e "${GREEN}Используется: UFW (Uncomplicated Firewall)${NC}"
            echo
            sudo ufw status verbose
            ;;
        firewalld)
            echo -e "${GREEN}Используется: FirewallD${NC}"
            echo
            echo -e "${BLUE}Статус:${NC}"
            sudo firewall-cmd --state
            echo
            echo -e "${BLUE}Активные правила:${NC}"
            sudo firewall-cmd --list-all
            ;;
        iptables)
            echo -e "${GREEN}Используется: iptables${NC}"
            echo
            echo -e "${BLUE}Правила фильтрации:${NC}"
            sudo iptables -L -n -v --line-numbers
            ;;
        none)
            echo -e "${RED}❌ Firewall не обнаружен в системе${NC}"
            echo
            echo -e "${YELLOW}Рекомендуется установить firewall для безопасности:${NC}"
            echo -e "${BLUE}  • Ubuntu/Debian: sudo apt install ufw${NC}"
            echo -e "${BLUE}  • RHEL/CentOS:   sudo yum install firewalld${NC}"
            ;;
    esac
    
    echo
    read -rp "Нажмите Enter для возврата в меню..."
}

# Меню управления портами
port_management() {
    while true; do
        clear
        show_banner
        echo
        echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║      🔒 Управление портами / Ports        ║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
        echo
        echo -e "${YELLOW}1)${NC} 🔓 Открыть порт / Open port"
        echo -e "${YELLOW}2)${NC} 🔒 Закрыть порт / Close port"
        echo -e "${YELLOW}3)${NC} ✏️  Редактировать описание / Edit description"
        echo -e "${YELLOW}4)${NC} 📋 Список портов / List ports"
        echo -e "${YELLOW}5)${NC} 🛡️  Статус firewall / Firewall status"
        echo -e "${YELLOW}0)${NC} ⬅️  Назад / Back"
        echo
        read -rp "$(echo -e ${BLUE}Выберите действие:${NC}) " choice
        
        case $choice in
            1) clear; show_banner; open_port ;;
            2) clear; show_banner; close_port ;;
            3) clear; show_banner; edit_port ;;
            4) clear; show_banner; list_ports; echo; read -rp "Нажмите Enter для возврата..." ;;
            5) clear; show_banner; show_firewall_status ;;
            0) break ;;
            *) echo -e "${RED}❌ Неверный выбор${NC}"; sleep 1 ;;
        esac
    done
}

# ====== ГЕНЕРАЦИЯ ID ======
ensure_xxd() {
    if command -v xxd >/dev/null 2>&1; then
        return 0
    fi
    echo -e "${YELLOW}⚙️  Утилита 'xxd' не найдена. Пытаюсь установить...${NC}"

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
        echo -e "${RED}❌ Не удалось определить пакетный менеджер. Установите 'vim-xxd' вручную.${NC}"
        return 1
    fi

    if command -v xxd >/dev/null 2>&1; then
        echo -e "${GREEN}✅ xxd успешно установлен!${NC}"
    else
        echo -e "${RED}❌ Не удалось установить xxd.${NC}"
        return 1
    fi
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
        echo -e "${RED}countries.csv not found in $DATA_DIR${NC}"; return
    fi
    matches=$(awk -F',' -v key="$key" '
    { ru=tolower($1); en=tolower($2); iso=$3;
      if (ru ~ key || en ~ key) { print iso "," $2; }
    }' "$COUNTRIES_FILE")
    if [ -z "$matches" ]; then
        echo -e "${RED}$(tr_text NOTHING_FOUND) '${input}'.${NC}"; return
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
        echo -e "${GREEN}$(tr_text NO_UPDATES)${NC}"; return 0
    fi
    echo -e "${YELLOW}$(tr_text UPDATE_AVAIL)${NC}"
    read -r ans
    [[ ! "$ans" =~ ^[YyДд]$ ]] && { echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"; return 0; }
    tmp_script="$SCRIPT_PATH.tmp"
    tmp_version="$DATA_DIR/version.txt.tmp"

    echo -e "${BLUE}⏳ Downloading update...${NC}"
    loading_bar & pid=$!
    if ! curl -fsSL -o "$tmp_script" "$REPO_URL/scripts.sh"; then
        kill $pid >/dev/null 2>&1; tput cnorm
        echo -e "\r${RED}$(tr_text UPDATE_FAIL)${NC}          "; rm -f "$tmp_script"; return 1
    fi
    if ! curl -fsSL -o "$tmp_version" "$REPO_URL/version.txt"; then
        kill $pid >/dev/null 2>&1; tput cnorm
        echo -e "\r${RED}$(tr_text UPDATE_FAIL)${NC}          "; rm -f "$tmp_script" "$tmp_version"; return 1
    fi
    kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm
    echo -e "\r✅ Update downloaded!                                   "

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
    echo -e "${YELLOW}$(tr_text MENU_MEMORY)${NC}"
    echo -e "${YELLOW}$(tr_text MENU_HTOP)${NC}"
    echo -e "${YELLOW}$(tr_text MENU_SYSINFO)${NC}"
    echo -e "${YELLOW}$(tr_text MENU_PORTS)${NC}"
    echo -e "${YELLOW}$(tr_text MENU_EXIT)${NC}"
    echo -n "> "
    read -r choice
    case $choice in
        1) generate_ids ;;
        2) country_lookup ;;
        3) check_update ;;
        4) delete_self ;;
        5) show_memory ;;
        6) launch_htop ;;
        7) show_system_info ;;
        8) port_management ;;
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