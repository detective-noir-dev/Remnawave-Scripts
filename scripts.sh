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
        figlet -f small "RW-Scripts"
        echo -e "          Remnawave-Scripts v$VERSION"
    else
        echo "==========================================="
        echo "  🚀 Remnawave-Scripts (v$VERSION)"
        echo "==========================================="
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
                SUB_APT_UPDATE)   echo "📦 Обновить системные пакеты" ;;
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
                APT_UPDATING)     echo "Обновление списка пакетов..." ;;
                APT_UPGRADING)    echo "Установка обновлений..." ;;
                APT_DONE)         echo "Все пакеты обновлены!" ;;
                APT_NOT_FOUND)    echo "apt не найден. Эта функция только для Debian/Ubuntu." ;;
                APT_CONFIRM)      echo "Обновить системные пакеты? Это может занять время. (y/n)" ;;
                APT_UPDATE_OK)    echo "Список пакетов обновлён!" ;;
                APT_UPDATE_FAIL)  echo "Ошибка при обновлении списка пакетов." ;;
                APT_UPGRADE_FAIL) echo "Ошибка при установке обновлений." ;;
                # === ПОДМЕНЮ: Server Setup ===
                GROUP_SERVER)         echo "🖥️  Настройка сервера" ;;
                SUB_SSH_PORT)         echo "🔑 Сменить SSH порт" ;;
                SUB_HY2_INSTALL)      echo "⚡ Установить Hysteria2" ;;
                SUB_HY2_REMOVE)       echo "🗑️  Удалить Hysteria2" ;;
                SUB_HY2_CONFIG)       echo "📝 Редактировать конфиг Hysteria2" ;;
                SUB_HY2_MANAGE)       echo "⚙️  Управление сервисом Hysteria2" ;;
                SUB_HY2_LOGS)         echo "📋 Логи Hysteria2" ;;
                SSH_ENTER_PORT)       echo "Введите новый SSH порт (1024-65535):" ;;
                SSH_INVALID_PORT)     echo "Ошибка: введите порт от 1024 до 65535!" ;;
                SSH_CONFIRM)          echo "Сменить SSH порт на" ;;
                SSH_CHANGED)          echo "SSH порт успешно изменён! Новый порт:" ;;
                SSH_RESTART)          echo "Перезапускаю SSH сервис..." ;;
                SSH_FAIL)             echo "Ошибка при смене порта!" ;;
                SSH_WARN)             echo "⚠️  ВНИМАНИЕ: Не закрывайте текущую SSH сессию!" ;;
                SSH_WARN2)            echo "Сначала откройте новое подключение на новом порту и проверьте что всё работает." ;;
                HY2_INSTALLING)       echo "Устанавливаю Hysteria2..." ;;
                HY2_INSTALLED)        echo "Hysteria2 успешно установлен!" ;;
                HY2_REMOVING)         echo "Удаляю Hysteria2..." ;;
                HY2_REMOVED)          echo "Hysteria2 успешно удалён!" ;;
                HY2_NOT_FOUND)        echo "Hysteria2 не найден в системе." ;;
                HY2_CONFIRM_REMOVE)   echo "Вы уверены, что хотите удалить Hysteria2? (y/n)" ;;
                HY2_DOMAIN_PROMPT)    echo "Введите ваш домен (например: example.com):" ;;
                HY2_PORT_PROMPT)      echo "Введите порт для Hysteria2 (по умолчанию 443):" ;;
                HY2_CONFIG_SAVED)     echo "Конфиг сохранён. Перезапустите сервис для применения изменений." ;;
                HY2_SVC_MENU)         echo "Управление сервисом Hysteria2" ;;
                HY2_SVC_ENABLE)       echo "▶️  Включить автозапуск и запустить" ;;
                HY2_SVC_RESTART)      echo "🔄 Перезапустить сервис" ;;
                HY2_SVC_STATUS)       echo "📊 Статус сервиса" ;;
                HY2_SVC_STOP)         echo "⏹️  Остановить сервис" ;;
                SUB_HY2_VERSION)      echo "🔍 Проверить версию Hysteria2" ;;
                SUB_HY2_UPDATE)       echo "⬆️  Обновить Hysteria2" ;;
                HY2_VERSION_CURR)     echo "Установленная версия:" ;;
                HY2_VERSION_LATEST)   echo "Последняя версия:" ;;
                HY2_UP_TO_DATE)       echo "У вас уже последняя версия Hysteria2!" ;;
                HY2_UPDATE_AVAIL)     echo "Доступно обновление! Обновить сейчас? (y/n)" ;;
                HY2_UPDATING)         echo "Обновляю Hysteria2..." ;;
                HY2_UPDATED)          echo "Hysteria2 успешно обновлён!" ;;
                HY2_UPDATE_FAIL)      echo "Ошибка при обновлении Hysteria2." ;;
                SUB_HY2_SUBMENU)      echo "⚡ Hysteria2" ;;
                SUB_ZAPRET)           echo "🛡️  Установка zapret" ;;
                ZAPRET_INSTALLING)    echo "Устанавливаю zapret..." ;;
                ZAPRET_DONE)          echo "Zapret успешно установлен!" ;;
                ZAPRET_FAIL)          echo "Ошибка при установке zapret." ;;
                # === ПОДМЕНЮ: Сторонние скрипты ===
                GROUP_THIRDPARTY)     echo "🔧 Сторонние скрипты" ;;
                SUB_EGAMES_RW)        echo "🌐 Remnawave (EGames)" ;;
                SUB_RESHALA)          echo "🤖 Reshala (Remnawave)" ;;
                EGAMES_INSTALLING)    echo "Устанавливаю Remnawave от EGames..." ;;
                EGAMES_DONE)          echo "Remnawave от EGames успешно установлен!" ;;
                EGAMES_FAIL)          echo "Ошибка установки Remnawave от EGames." ;;
                RESHALA_INSTALLING)   echo "Устанавливаю Reshala..." ;;
                RESHALA_DONE)         echo "Reshala успешно установлен!" ;;
                RESHALA_FAIL)         echo "Ошибка установки Reshala." ;;
                BASHRC_RELOAD)        echo "⚠️  Перезапустите терминал или выполните: source ~/.bashrc" ;;
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
                SUB_APT_UPDATE)   echo "📦 Update system packages" ;;
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
                APT_UPDATING)     echo "Updating package lists..." ;;
                APT_UPGRADING)    echo "Installing updates..." ;;
                APT_DONE)         echo "All packages updated!" ;;
                APT_NOT_FOUND)    echo "apt not found. This feature is for Debian/Ubuntu only." ;;
                APT_CONFIRM)      echo "Update system packages? This may take a while. (y/n)" ;;
                APT_UPDATE_OK)    echo "Package lists updated!" ;;
                APT_UPDATE_FAIL)  echo "Failed to update package lists." ;;
                APT_UPGRADE_FAIL) echo "Failed to install updates." ;;
                # === SUBMENU: Server Setup ===
                GROUP_SERVER)         echo "🖥️  Server Setup" ;;
                SUB_SSH_PORT)         echo "🔑 Change SSH port" ;;
                SUB_HY2_INSTALL)      echo "⚡ Install Hysteria2" ;;
                SUB_HY2_REMOVE)       echo "🗑️  Remove Hysteria2" ;;
                SUB_HY2_CONFIG)       echo "📝 Edit Hysteria2 config" ;;
                SUB_HY2_MANAGE)       echo "⚙️  Manage Hysteria2 service" ;;
                SUB_HY2_LOGS)         echo "📋 Hysteria2 logs" ;;
                SSH_ENTER_PORT)       echo "Enter new SSH port (1024-65535):" ;;
                SSH_INVALID_PORT)     echo "Error: enter a port from 1024 to 65535!" ;;
                SSH_CONFIRM)          echo "Change SSH port to" ;;
                SSH_CHANGED)          echo "SSH port changed successfully! New port:" ;;
                SSH_RESTART)          echo "Restarting SSH service..." ;;
                SSH_FAIL)             echo "Error changing port!" ;;
                SSH_WARN)             echo "⚠️  WARNING: Do NOT close your current SSH session!" ;;
                SSH_WARN2)            echo "Open a new connection on the new port first and verify it works." ;;
                HY2_INSTALLING)       echo "Installing Hysteria2..." ;;
                HY2_INSTALLED)        echo "Hysteria2 installed successfully!" ;;
                HY2_REMOVING)         echo "Removing Hysteria2..." ;;
                HY2_REMOVED)          echo "Hysteria2 removed successfully!" ;;
                HY2_NOT_FOUND)        echo "Hysteria2 not found on this system." ;;
                HY2_CONFIRM_REMOVE)   echo "Are you sure you want to remove Hysteria2? (y/n)" ;;
                HY2_DOMAIN_PROMPT)    echo "Enter your domain (e.g. example.com):" ;;
                HY2_PORT_PROMPT)      echo "Enter port for Hysteria2 (default 443):" ;;
                HY2_CONFIG_SAVED)     echo "Config saved. Restart the service to apply changes." ;;
                HY2_SVC_MENU)         echo "Hysteria2 service management" ;;
                HY2_SVC_ENABLE)       echo "▶️  Enable autostart and start" ;;
                HY2_SVC_RESTART)      echo "🔄 Restart service" ;;
                HY2_SVC_STATUS)       echo "📊 Service status" ;;
                HY2_SVC_STOP)         echo "⏹️  Stop service" ;;
                SUB_HY2_VERSION)      echo "🔍 Check Hysteria2 version" ;;
                SUB_HY2_UPDATE)       echo "⬆️  Update Hysteria2" ;;
                HY2_VERSION_CURR)     echo "Installed version:" ;;
                HY2_VERSION_LATEST)   echo "Latest version:" ;;
                HY2_UP_TO_DATE)       echo "You already have the latest Hysteria2!" ;;
                HY2_UPDATE_AVAIL)     echo "Update available! Update now? (y/n)" ;;
                HY2_UPDATING)         echo "Updating Hysteria2..." ;;
                HY2_UPDATED)          echo "Hysteria2 updated successfully!" ;;
                HY2_UPDATE_FAIL)      echo "Failed to update Hysteria2." ;;
                SUB_HY2_SUBMENU)      echo "⚡ Hysteria2" ;;
                SUB_ZAPRET)           echo "🛡️  Install zapret" ;;
                ZAPRET_INSTALLING)    echo "Installing zapret..." ;;
                ZAPRET_DONE)          echo "Zapret installed successfully!" ;;
                ZAPRET_FAIL)          echo "Failed to install zapret." ;;
                # === SUBMENU: Third-party Scripts ===
                GROUP_THIRDPARTY)     echo "🔧 Third-party Scripts" ;;
                SUB_EGAMES_RW)        echo "🌐 Remnawave (EGames)" ;;
                SUB_RESHALA)          echo "🤖 Reshala (Remnawave)" ;;
                EGAMES_INSTALLING)    echo "Installing Remnawave by EGames..." ;;
                EGAMES_DONE)          echo "Remnawave by EGames installed successfully!" ;;
                EGAMES_FAIL)          echo "Failed to install Remnawave by EGames." ;;
                RESHALA_INSTALLING)   echo "Installing Reshala..." ;;
                RESHALA_DONE)         echo "Reshala installed successfully!" ;;
                RESHALA_FAIL)         echo "Failed to install Reshala." ;;
                BASHRC_RELOAD)        echo "⚠️  Restart your terminal or run: source ~/.bashrc" ;;
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

# ====== ПОЛУЧЕНИЕ РЕАЛЬНЫХ ОТКРЫТЫХ ПОРТОВ ИЗ FIREWALL ======
get_firewall_ports() {
    local firewall=$(detect_firewall)
    local ports_list=""
    
    case $firewall in
        ufw)
            # Парсим вывод ufw status
            ports_list=$(sudo ufw status 2>/dev/null | grep -E "^[0-9]+/(tcp|udp)" | while read line; do
                port=$(echo "$line" | grep -oE "^[0-9]+" | head -1)
                proto=$(echo "$line" | grep -oE "(tcp|udp)" | head -1)
                echo "$port|$proto"
            done)
            
            # Также парсим порты в формате "443/tcp ALLOW"
            ports_list+=$(sudo ufw status 2>/dev/null | grep -E "ALLOW" | grep -oE "[0-9]+/(tcp|udp)" | while read line; do
                port=$(echo "$line" | cut -d'/' -f1)
                proto=$(echo "$line" | cut -d'/' -f2)
                echo "$port|$proto"
            done)
            ;;
        firewalld)
            # Получаем порты из firewalld
            ports_list=$(sudo firewall-cmd --list-ports 2>/dev/null | tr ' ' '\n' | while read line; do
                if [ -n "$line" ]; then
                    port=$(echo "$line" | cut -d'/' -f1)
                    proto=$(echo "$line" | cut -d'/' -f2)
                    echo "$port|$proto"
                fi
            done)
            ;;
        iptables)
            # Парсим iptables для открытых портов
            ports_list=$(sudo iptables -L INPUT -n 2>/dev/null | grep -E "ACCEPT.*dpt:" | while read line; do
                proto=$(echo "$line" | awk '{print tolower($2)}')
                port=$(echo "$line" | grep -oE "dpt:[0-9]+" | cut -d':' -f2)
                if [ -n "$port" ]; then
                    echo "$port|$proto"
                fi
            done)
            ;;
    esac
    
    echo "$ports_list" | sort -u | grep -v "^$"
}

# ====== СИНХРОНИЗАЦИЯ ПОРТОВ С JSON ======
sync_ports_with_firewall() {
    ensure_jq || return 1
    init_ports_file
    
    local firewall_ports=$(get_firewall_ports)
    
    # Проходим по каждому порту из firewall
    echo "$firewall_ports" | while IFS='|' read -r port proto; do
        if [ -n "$port" ] && [ -n "$proto" ]; then
            # Проверяем, есть ли уже этот порт в JSON
            local exists=$(jq -r ".[] | select(.port == \"$port\" and .protocol == \"$proto\") | .port" "$PORTS_FILE" 2>/dev/null)
            
            if [ -z "$exists" ]; then
                # Добавляем порт в JSON с пометкой что он был открыт до скрипта
                local timestamp=$(date +%s)
                local temp_file=$(mktemp)
                jq ". += [{\"port\": \"$port\", \"protocol\": \"$proto\", \"description\": \"[System] Opened before script\", \"timestamp\": $timestamp, \"source\": \"system\"}]" "$PORTS_FILE" > "$temp_file"
                mv "$temp_file" "$PORTS_FILE"
            fi
        fi
    done
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
    
    # Синхронизируем перед показом
    sync_ports_with_firewall
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
    # Синхронизируем перед показом
    sync_ports_with_firewall
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
    
    # Синхронизируем порты с firewall
    echo -e "${DIM}🔄 Синхронизация с firewall...${NC}"
    sync_ports_with_firewall
    
    if [ ! -s "$PORTS_FILE" ] || [ "$(cat "$PORTS_FILE")" = "[]" ]; then
        echo -e "${YELLOW}📭 Нет открытых портов${NC}"
        return
    fi
    
    ensure_jq || return 1
    
    echo
    echo -e "${BLUE}┌─────────┬───────────┬──────────────────────────────────────┬──────────┐${NC}"
    echo -e "${BLUE}│${NC} ${MAGENTA}Port${NC}    ${BLUE}│${NC} ${MAGENTA}Protocol${NC}  ${BLUE}│${NC} ${MAGENTA}Description${NC}                          ${BLUE}│${NC} ${MAGENTA}Source${NC}   ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────┼───────────┼──────────────────────────────────────┼──────────┤${NC}"
    
    jq -r '.[] | "\(.port)|\(.protocol)|\(.description)|\(.source // "script")"' "$PORTS_FILE" | while IFS='|' read -r port proto desc source; do
        [ ${#desc} -gt 36 ] && desc="${desc:0:33}..."
        
        # Определяем цвет для источника
        if [ "$source" = "system" ]; then
            source_display="${DIM}system${NC}"
        else
            source_display="${GREEN}script${NC}"
        fi
        
        printf "${BLUE}│${NC} ${GREEN}%-7s${NC} ${BLUE}│${NC} ${YELLOW}%-9s${NC} ${BLUE}│${NC} %-36s ${BLUE}│${NC} %-17b ${BLUE}│${NC}\n" "$port" "$proto" "$desc" "$source_display"
    done
    
    echo -e "${BLUE}└─────────┴───────────┴──────────────────────────────────────┴──────────┘${NC}"
    
    local total=$(jq '. | length' "$PORTS_FILE")
    local script_count=$(jq '[.[] | select(.source != "system")] | length' "$PORTS_FILE")
    local system_count=$(jq '[.[] | select(.source == "system")] | length' "$PORTS_FILE")
    
    echo -e "${CYAN}📊 Всего: $total | Через скрипт: $script_count | Системные: $system_count${NC}"
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
#                     НАСТРОЙКА СЕРВЕРА
# ══════════════════════════════════════════════════════════════════

# ====== СМЕНА SSH ПОРТА ======
change_ssh_port() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    🔑 $(tr_text SUB_SSH_PORT)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo

    local sshd_config="/etc/ssh/sshd_config"
    local current_port
    current_port=$(grep -E "^Port " "$sshd_config" 2>/dev/null | awk '{print $2}' | head -1)
    [ -z "$current_port" ] && current_port="22"

    echo -e "${BLUE}Текущий SSH порт / Current SSH port: ${YELLOW}${current_port}${NC}"
    echo
    echo -e "${RED}$(tr_text SSH_WARN)${NC}"
    echo -e "${YELLOW}$(tr_text SSH_WARN2)${NC}"
    echo

    echo -e "${BLUE}$(tr_text SSH_ENTER_PORT)${NC}"
    read -r new_port

    if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1024 ] || [ "$new_port" -gt 65535 ]; then
        echo -e "${RED}❌ $(tr_text SSH_INVALID_PORT)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    echo -e "${YELLOW}$(tr_text SSH_CONFIRM) ${CYAN}${new_port}${YELLOW}? (y/n)${NC}"
    read -r ans
    if [[ ! "$ans" =~ ^[YyДд]$ ]]; then
        echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi

    # Меняем порт в конфиге
    if grep -qE "^Port " "$sshd_config" 2>/dev/null; then
        sudo sed -i "s/^Port .*/Port $new_port/" "$sshd_config"
    elif grep -qE "^#Port " "$sshd_config" 2>/dev/null; then
        sudo sed -i "s/^#Port .*/Port $new_port/" "$sshd_config"
    else
        echo "Port $new_port" | sudo tee -a "$sshd_config" > /dev/null
    fi

    # Открываем новый порт в firewall
    local firewall
    firewall=$(detect_firewall)
    case $firewall in
        ufw)
            sudo ufw allow "$new_port"/tcp >/dev/null 2>&1
            echo -e "${GREEN}✅ Порт $new_port открыт в UFW${NC}"
            ;;
        firewalld)
            sudo firewall-cmd --permanent --add-port="$new_port"/tcp >/dev/null 2>&1
            sudo firewall-cmd --reload >/dev/null 2>&1
            echo -e "${GREEN}✅ Порт $new_port открыт в FirewallD${NC}"
            ;;
        iptables)
            sudo iptables -A INPUT -p tcp --dport "$new_port" -j ACCEPT 2>/dev/null
            echo -e "${GREEN}✅ Порт $new_port открыт в iptables${NC}"
            ;;
    esac

    # Перезапускаем SSH
    echo -e "${BLUE}$(tr_text SSH_RESTART)${NC}"
    if sudo systemctl restart sshd 2>/dev/null || sudo systemctl restart ssh 2>/dev/null; then
        echo
        echo -e "${GREEN}✅ $(tr_text SSH_CHANGED) ${CYAN}${new_port}${NC}"
        echo
        echo -e "${CYAN}Подключайтесь командой / Connect with:${NC}"
        echo -e "  ${YELLOW}ssh -p ${new_port} $(whoami)@<your_server_ip>${NC}"
    else
        echo -e "${RED}❌ $(tr_text SSH_FAIL)${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== УСТАНОВКА HYSTERIA2 ======
install_hysteria2() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    ⚡ $(tr_text SUB_HY2_INSTALL)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo

    # Если уже установлен — показываем версию и предлагаем переустановить/обновить
    if command -v hysteria >/dev/null 2>&1 || [ -f /usr/local/bin/hysteria ]; then
        local ver
        ver=$(hysteria version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        echo -e "${YELLOW}⚠️  Hysteria2 уже установлен / Already installed: ${GREEN}${ver}${NC}"
        echo -e "${DIM}Команда bash <(curl -fsSL https://get.hy2.sh/) также обновит до последней версии.${NC}"
        echo
        echo -e "${YELLOW}Запустить установщик заново? (y/n)${NC}"
        read -r ans
        [[ ! "$ans" =~ ^[YyДд]$ ]] && { read -rp "$(tr_text PRESS_ENTER)"; return 0; }
        echo
    fi

    echo -e "${BLUE}$(tr_text HY2_INSTALLING)${NC}"
    echo -e "${DIM}Команда: bash <(curl -fsSL https://get.hy2.sh/)${NC}"
    echo

    bash <(curl -fsSL https://get.hy2.sh/)
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        local new_ver
        new_ver=$(hysteria version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        echo -e "${GREEN}✅ $(tr_text HY2_INSTALLED)${NC}"
        [ -n "$new_ver" ] && echo -e "${CYAN}Версия / Version: ${YELLOW}${new_ver}${NC}"
        echo
        echo -e "${CYAN}Следующий шаг:${NC} Настройте конфиг → пункт ${YELLOW}4) $(tr_text SUB_HY2_CONFIG)${NC}"
    else
        echo -e "${RED}❌ Ошибка установки / Installation failed.${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== УДАЛЕНИЕ HYSTERIA2 ======
remove_hysteria2() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    🗑️  $(tr_text SUB_HY2_REMOVE)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo

    if ! command -v hysteria >/dev/null 2>&1 && [ ! -f /usr/local/bin/hysteria ]; then
        echo -e "${YELLOW}$(tr_text HY2_NOT_FOUND)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi

    echo -e "${RED}$(tr_text HY2_CONFIRM_REMOVE)${NC}"
    read -r ans
    if [[ ! "$ans" =~ ^[YyДд]$ ]]; then
        echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi

    echo -e "${BLUE}$(tr_text HY2_REMOVING)${NC}"
    echo

    bash <(curl -fsSL https://get.hy2.sh/) --remove
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ $(tr_text HY2_REMOVED)${NC}"
    else
        echo -e "${RED}❌ Ошибка удаления / Removal failed.${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== РЕДАКТИРОВАНИЕ КОНФИГА HYSTERIA2 ======
edit_hysteria2_config() {
    local config_file="/etc/hysteria/config.yaml"

    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    📝 $(tr_text SUB_HY2_CONFIG)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo

    if [ ! -f "$config_file" ]; then
        echo -e "${YELLOW}⚠️  Конфиг не найден. Создаём базовый конфиг...${NC}"
        echo

        echo -e "${BLUE}$(tr_text HY2_DOMAIN_PROMPT)${NC}"
        read -r hy2_domain
        [ -z "$hy2_domain" ] && hy2_domain="example.com"

        echo -e "${BLUE}$(tr_text HY2_PORT_PROMPT)${NC}"
        read -r hy2_port
        if ! [[ "$hy2_port" =~ ^[0-9]+$ ]] || [ "$hy2_port" -lt 1 ] || [ "$hy2_port" -gt 65535 ]; then
            hy2_port="443"
        fi

        sudo mkdir -p /etc/hysteria

        sudo tee "$config_file" > /dev/null <<HYEOF
listen: :${hy2_port}

tls:
  cert: /etc/hysteria/server.crt
  key: /etc/hysteria/server.key

# Для автоматического TLS (ACME) раскомментируйте:
# acme:
#   domains:
#     - ${hy2_domain}
#   email: admin@${hy2_domain}

auth:
  type: password
  password: your_strong_password_here

masquerade:
  type: proxy
  proxy:
    url: https://news.ycombinator.com/
    rewriteHost: true
HYEOF

        echo -e "${GREEN}✅ Базовый конфиг создан: ${CYAN}${config_file}${NC}"
        echo -e "   ${BLUE}Домен / Domain: ${YELLOW}${hy2_domain}${NC}"
        echo -e "   ${BLUE}Порт / Port:    ${YELLOW}${hy2_port}${NC}"
        echo
        sleep 1
    fi

    echo -e "${YELLOW}Открываю конфиг в редакторе / Opening config...${NC}"
    sleep 1

    if command -v nano >/dev/null 2>&1; then
        sudo nano "$config_file"
    elif command -v vim >/dev/null 2>&1; then
        sudo vim "$config_file"
    elif command -v vi >/dev/null 2>&1; then
        sudo vi "$config_file"
    else
        echo -e "${RED}❌ Редактор не найден. Установите nano: sudo apt install nano${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    echo
    echo -e "${GREEN}✅ $(tr_text HY2_CONFIG_SAVED)${NC}"
    echo -e "${CYAN}Путь к конфигу / Config path: ${YELLOW}${config_file}${NC}"
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== УПРАВЛЕНИЕ СЕРВИСОМ HYSTERIA2 ======
manage_hysteria2_service() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text HY2_SVC_MENU)"

        echo -e "  ${YELLOW}1)${NC} $(tr_text HY2_SVC_ENABLE)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text HY2_SVC_RESTART)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text HY2_SVC_STATUS)"
        echo -e "  ${YELLOW}4)${NC} $(tr_text HY2_SVC_STOP)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice

        case $choice in
            1)
                show_banner
                echo -e "${BLUE}▶️  Включаю автозапуск и запускаю hysteria-server.service...${NC}"
                echo
                sudo systemctl enable --now hysteria-server.service
                echo
                echo -e "${GREEN}✅ Сервис включён и запущен.${NC}"
                echo
                read -rp "$(tr_text PRESS_ENTER)"
                ;;
            2)
                show_banner
                echo -e "${BLUE}🔄 Перезапускаю hysteria-server.service...${NC}"
                echo
                sudo systemctl restart hysteria-server.service
                echo
                echo -e "${GREEN}✅ Сервис перезапущен.${NC}"
                echo
                read -rp "$(tr_text PRESS_ENTER)"
                ;;
            3)
                show_banner
                echo -e "${CYAN}📊 Статус hysteria-server.service:${NC}"
                echo
                sudo systemctl status hysteria-server.service --no-pager -l
                echo
                read -rp "$(tr_text PRESS_ENTER)"
                ;;
            4)
                show_banner
                echo -e "${YELLOW}⏹️  Останавливаю hysteria-server.service...${NC}"
                echo
                sudo systemctl stop hysteria-server.service
                echo
                echo -e "${YELLOW}✅ Сервис остановлен.${NC}"
                echo
                read -rp "$(tr_text PRESS_ENTER)"
                ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ====== ПРОСМОТР ЛОГОВ HYSTERIA2 ======
show_hysteria2_logs() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    📋 $(tr_text SUB_HY2_LOGS)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${YELLOW}Нажмите Ctrl+C для выхода / Press Ctrl+C to exit${NC}"
    echo
    sleep 1
    sudo journalctl --no-pager -e -u hysteria-server.service
    echo
    read -rp "$(tr_text PRESS_ENTER)"
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

# ====== ПОДМЕНЮ 5: Server Setup ======
# ====== ПРОВЕРКА ВЕРСИИ HYSTERIA2 ======
check_hysteria2_version() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    🔍 $(tr_text SUB_HY2_VERSION)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo

    # Установленная версия
    local installed_ver=""
    if command -v hysteria >/dev/null 2>&1; then
        installed_ver=$(hysteria version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    elif [ -f /usr/local/bin/hysteria ]; then
        installed_ver=$(/usr/local/bin/hysteria version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    fi

    if [ -z "$installed_ver" ]; then
        echo -e "${YELLOW}$(tr_text HY2_NOT_FOUND)${NC}"
        echo
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi

    echo -e "${BLUE}$(tr_text HY2_VERSION_CURR)${NC} ${GREEN}${installed_ver}${NC}"

    # Последняя версия с GitHub
    echo -e "${DIM}Проверяю последнюю версию...${NC}"
    local latest_ver
    latest_ver=$(curl -fsSL "https://api.github.com/repos/apernet/hysteria/releases/latest" 2>/dev/null \
        | grep '"tag_name"' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)

    if [ -z "$latest_ver" ]; then
        echo -e "${YELLOW}⚠️  Не удалось получить информацию о последней версии.${NC}"
    else
        echo -e "${BLUE}$(tr_text HY2_VERSION_LATEST)${NC} ${CYAN}${latest_ver}${NC}"
        echo
        if [ "$installed_ver" = "$latest_ver" ]; then
            echo -e "${GREEN}✅ $(tr_text HY2_UP_TO_DATE)${NC}"
        else
            echo -e "${YELLOW}⚠️  $(tr_text HY2_UPDATE_AVAIL)${NC}"
            echo -e "${DIM}   Используйте пункт '$(tr_text SUB_HY2_UPDATE)' для обновления.${NC}"
        fi
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== ОБНОВЛЕНИЕ HYSTERIA2 ======
update_hysteria2() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    ⬆️  $(tr_text SUB_HY2_UPDATE)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo

    if ! command -v hysteria >/dev/null 2>&1 && [ ! -f /usr/local/bin/hysteria ]; then
        echo -e "${YELLOW}$(tr_text HY2_NOT_FOUND)${NC}"
        echo -e "${DIM}Сначала установите Hysteria2 через пункт '$(tr_text SUB_HY2_INSTALL)'${NC}"
        echo
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi

    # Показываем текущую версию
    local installed_ver
    installed_ver=$(hysteria version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    [ -z "$installed_ver" ] && installed_ver="unknown"

    # Получаем последнюю версию
    local latest_ver
    latest_ver=$(curl -fsSL "https://api.github.com/repos/apernet/hysteria/releases/latest" 2>/dev/null \
        | grep '"tag_name"' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)

    echo -e "${BLUE}$(tr_text HY2_VERSION_CURR)${NC} ${GREEN}${installed_ver}${NC}"

    if [ -n "$latest_ver" ]; then
        echo -e "${BLUE}$(tr_text HY2_VERSION_LATEST)${NC} ${CYAN}${latest_ver}${NC}"
        echo

        if [ "$installed_ver" = "$latest_ver" ]; then
            echo -e "${GREEN}✅ $(tr_text HY2_UP_TO_DATE)${NC}"
            echo
            read -rp "$(tr_text PRESS_ENTER)"
            return 0
        fi

        echo -e "${YELLOW}$(tr_text HY2_UPDATE_AVAIL)${NC}"
        read -r ans
        if [[ ! "$ans" =~ ^[YyДд]$ ]]; then
            echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 0
        fi
    else
        echo -e "${YELLOW}⚠️  Не удалось проверить последнюю версию. Всё равно обновить? (y/n)${NC}"
        read -r ans
        [[ ! "$ans" =~ ^[YyДд]$ ]] && { read -rp "$(tr_text PRESS_ENTER)"; return 0; }
    fi

    echo
    echo -e "${BLUE}$(tr_text HY2_UPDATING)${NC}"
    echo -e "${DIM}Команда: bash <(curl -fsSL https://get.hy2.sh/)${NC}"
    echo

    # Официальный установщик — устанавливает или обновляет до последней версии
    bash <(curl -fsSL https://get.hy2.sh/)
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        local new_ver
        new_ver=$(hysteria version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        echo -e "${GREEN}✅ $(tr_text HY2_UPDATED)${NC}"
        [ -n "$new_ver" ] && echo -e "${CYAN}Новая версия / New version: ${YELLOW}${new_ver}${NC}"
        echo
        echo -e "${DIM}Перезапустите сервис для применения: пункт 5 → 2${NC}"
    else
        echo -e "${RED}❌ $(tr_text HY2_UPDATE_FAIL)${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

submenu_hysteria2() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text SUB_HY2_SUBMENU)"

        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_HY2_INSTALL)"
        echo -e "  ${RED}2)${NC} $(tr_text SUB_HY2_REMOVE)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text SUB_HY2_CONFIG)"
        echo -e "  ${YELLOW}4)${NC} $(tr_text SUB_HY2_MANAGE)"
        echo -e "  ${YELLOW}5)${NC} $(tr_text SUB_HY2_LOGS)"
        echo -e "  ${YELLOW}6)${NC} $(tr_text SUB_HY2_VERSION)"
        echo -e "  ${YELLOW}7)${NC} $(tr_text SUB_HY2_UPDATE)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice

        case $choice in
            1) show_banner; install_hysteria2 ;;
            2) show_banner; remove_hysteria2 ;;
            3) show_banner; edit_hysteria2_config ;;
            4) manage_hysteria2_service ;;
            5) show_banner; show_hysteria2_logs ;;
            6) show_banner; check_hysteria2_version ;;
            7) show_banner; update_hysteria2 ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

install_zapret() {
    echo -e "${BLUE}🛡️  $(tr_text ZAPRET_INSTALLING)${NC}"
    echo
    if curl -O https://raw.githubusercontent.com/IndeecFOX/z4r/4/z4r && sh z4r; then
        echo
        echo -e "${GREEN}✅ $(tr_text ZAPRET_DONE)${NC}"
    else
        echo
        echo -e "${RED}❌ $(tr_text ZAPRET_FAIL)${NC}"
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== УСТАНОВКА REMNAWAVE ОТ EGAMES ======
install_egames_remnawave() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    🌐 $(tr_text SUB_EGAMES_RW)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}$(tr_text EGAMES_INSTALLING)${NC}"
    echo -e "${DIM}Script: eGamesAPI/remnawave-reverse-proxy${NC}"
    echo

    bash <(curl -Ls https://raw.githubusercontent.com/eGamesAPI/remnawave-reverse-proxy/refs/heads/main/install_remnawave.sh)
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ $(tr_text EGAMES_DONE)${NC}"
        echo
        # Применяем bashrc в текущем shell
        # shellcheck disable=SC1090
        [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" 2>/dev/null || true
        echo -e "${YELLOW}$(tr_text BASHRC_RELOAD)${NC}"
    else
        echo -e "${RED}❌ $(tr_text EGAMES_FAIL)${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== УСТАНОВКА RESHALA ======
install_reshala() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    🤖 $(tr_text SUB_RESHALA)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}$(tr_text RESHALA_INSTALLING)${NC}"
    echo -e "${DIM}Script: DonMatteoVPN/Reshala-Remnawave-Bedolaga${NC}"
    echo

    local tmp_install
    tmp_install=$(mktemp /tmp/reshala_install_XXXXXX.sh)
    wget -q -O "$tmp_install" https://raw.githubusercontent.com/DonMatteoVPN/Reshala-Remnawave-Bedolaga/main/install.sh \
        && bash "$tmp_install"
    local status=$?
    rm -f "$tmp_install"

    echo
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ $(tr_text RESHALA_DONE)${NC}"
        echo
        # Применяем bashrc в текущем shell
        # shellcheck disable=SC1090
        [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" 2>/dev/null || true
        echo -e "${YELLOW}$(tr_text BASHRC_RELOAD)${NC}"
        echo
        echo -e "${CYAN}Запуск reshala...${NC}"
        sleep 1
        if command -v reshala >/dev/null 2>&1; then
            reshala
        else
            echo -e "${YELLOW}⚠️  'reshala' не найден в PATH. Откройте новый терминал и выполните: reshala${NC}"
        fi
    else
        echo -e "${RED}❌ $(tr_text RESHALA_FAIL)${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== ПОДМЕНЮ: СТОРОННИЕ СКРИПТЫ ======
submenu_thirdparty() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_THIRDPARTY)"

        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_EGAMES_RW)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_RESHALA)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice

        case $choice in
            1) show_banner; install_egames_remnawave ;;
            2) show_banner; install_reshala ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

submenu_server() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_SERVER)"

        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_SSH_PORT)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_ZAPRET)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text SUB_HY2_SUBMENU)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice

        case $choice in
            1) show_banner; change_ssh_port ;;
            2) show_banner; install_zapret ;;
            3) submenu_hysteria2 ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
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
        sudo apt update &>/dev/null
        local update_status=$?
    else
        sudo apt-get update &>/dev/null
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
        sudo apt upgrade -y &>/dev/null
        local upgrade_status=$?
    else
        sudo apt-get upgrade -y &>/dev/null
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
# ====== ПОДМЕНЮ 4: Maintenance ======
submenu_maintenance() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_SETTINGS)"
        
        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_UPDATE)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_APT_UPDATE)"
        echo -e "  ${RED}3)${NC} $(tr_text SUB_DELETE)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        
        case $choice in
            1) show_banner; check_update ;;
            2) show_banner; apt_update_upgrade ;;
            3) show_banner; delete_self ;;
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
        echo -e "  ${YELLOW}5)${NC} $(tr_text GROUP_SERVER)"
        echo -e "  ${YELLOW}6)${NC} $(tr_text GROUP_THIRDPARTY)"
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
            5) submenu_server ;;
            6) submenu_thirdparty ;;
            0) echo -e "${GREEN}$(tr_text MSG_EXIT)${NC}"; exit 0 ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ====== ЗАПУСК ======
show_main_menu