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
                SUB_MULTITEST)        echo "🧪 Multitest" ;;
                MULTITEST_INSTALLING) echo "Устанавливаю Multitest..." ;;
                MULTITEST_DONE)       echo "Multitest успешно установлен!" ;;
                MULTITEST_FAIL)       echo "Ошибка установки Multitest." ;;
                # === ОЧИСТКА СИСТЕМЫ ===
                GROUP_CLEANER)        echo "🧹 Очистка системы" ;;
                CLEAN_ALL)            echo "✨ Полная уборка (всё сразу)" ;;
                CLEAN_APT)            echo "📦 Очистить APT и кэш пакетов" ;;
                CLEAN_JOURNAL)        echo "📚 Очистить системные логи (journald)" ;;
                CLEAN_DOCKER)         echo "🐳 Очистить мусор Docker (prune)" ;;
                CLEAN_TMP)            echo "🗑️  Очистить /tmp и кэш пользователя" ;;
                CLEAN_SNAP)           echo "🧩 Очистить старые Snap-пакеты" ;;
                CLEAN_DISK_ANALY)     echo "🔍 Анализатор диска" ;;
                CLEAN_NO_DOCKER)      echo "Docker не установлен." ;;
                CLEAN_NO_SNAP)        echo "Snap не установлен." ;;
                # === ПАМЯТЬ И SWAP ===
                GROUP_MEMORY)         echo "🧠 Управление памятью и Swap" ;;
                MEM_HYBRID)           echo "🌪️  Гибридный режим (ZRAM + Swap) [РЕКОМЕНДУЕТСЯ]" ;;
                MEM_ZRAM_ONLY)        echo "🧩 Только ZRAM (турбо-сжатие)" ;;
                MEM_SWAP_ONLY)        echo "💽 Только Disk Swap" ;;
                MEM_REMOVE_ALL)       echo "🗑️  Отключить ZRAM/Swap полностью" ;;
                MEM_SHOW_STATUS)      echo "📊 Подробный статус памяти" ;;
                MEM_INSTRUCTIONS)     echo "📖 Инструкция (лимиты Docker)" ;;
                MEM_ZRAM_PERCENT)     echo "Введите процент сжатия (10-100, по умолчанию 60):" ;;
                MEM_SWAP_SIZE)        echo "Введите размер в GB (например, 2):" ;;
                # === REALITY SCANNER ===
                GROUP_SCANNER)        echo "🔍 Reality TLS Scanner" ;;
                SCAN_SINGLE)          echo "🔬 Одиночное сканирование (OSINT)" ;;
                SCAN_MASS)            echo "🕵️  Массовый пробив по списку" ;;
                SCAN_TARGET)          echo "Введите цель (IP или домен):" ;;
                SCAN_PORT)            echo "Порт(ы) через запятую (Enter = 443):" ;;
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
                SUB_MULTITEST)        echo "🧪 Multitest" ;;
                MULTITEST_INSTALLING) echo "Installing Multitest..." ;;
                MULTITEST_DONE)       echo "Multitest installed successfully!" ;;
                MULTITEST_FAIL)       echo "Failed to install Multitest." ;;
                # === SYSTEM CLEANER ===
                GROUP_CLEANER)        echo "🧹 System Cleaner" ;;
                CLEAN_ALL)            echo "✨ Full cleanup (everything)" ;;
                CLEAN_APT)            echo "📦 Clean APT cache" ;;
                CLEAN_JOURNAL)        echo "📚 Clean system logs (journald)" ;;
                CLEAN_DOCKER)         echo "🐳 Clean Docker garbage (prune)" ;;
                CLEAN_TMP)            echo "🗑️  Clean /tmp and user cache" ;;
                CLEAN_SNAP)           echo "🧩 Clean old Snap packages" ;;
                CLEAN_DISK_ANALY)     echo "🔍 Disk analyzer" ;;
                CLEAN_NO_DOCKER)      echo "Docker is not installed." ;;
                CLEAN_NO_SNAP)        echo "Snap is not installed." ;;
                # === MEMORY & SWAP ===
                GROUP_MEMORY)         echo "🧠 Memory & Swap Manager" ;;
                MEM_HYBRID)           echo "🌪️  Hybrid mode (ZRAM + Swap) [RECOMMENDED]" ;;
                MEM_ZRAM_ONLY)        echo "🧩 ZRAM only (turbo compression)" ;;
                MEM_SWAP_ONLY)        echo "💽 Disk Swap only" ;;
                MEM_REMOVE_ALL)       echo "🗑️  Disable ZRAM/Swap completely" ;;
                MEM_SHOW_STATUS)      echo "📊 Detailed memory status" ;;
                MEM_INSTRUCTIONS)     echo "📖 Guide (Docker memory limits)" ;;
                MEM_ZRAM_PERCENT)     echo "Enter compression percent (10-100, default 60):" ;;
                MEM_SWAP_SIZE)        echo "Enter size in GB (e.g. 2):" ;;
                # === REALITY SCANNER ===
                GROUP_SCANNER)        echo "🔍 Reality TLS Scanner" ;;
                SCAN_SINGLE)          echo "🔬 Single scan (OSINT)" ;;
                SCAN_MASS)            echo "🕵️  Mass scan from list" ;;
                SCAN_TARGET)          echo "Enter target (IP or domain):" ;;
                SCAN_PORT)            echo "Port(s) comma-separated (Enter = 443):" ;;
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

# ====== УСТАНОВКА MULTITEST ======
install_multitest() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    $(tr_text SUB_MULTITEST)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}$(tr_text MULTITEST_INSTALLING)${NC}"
    echo -e "${DIM}Script: saveksme/multitest${NC}"
    echo

    curl -sL https://raw.githubusercontent.com/saveksme/multitest/master/multitest.sh \
        -o /usr/local/bin/multitest && chmod +x /usr/local/bin/multitest
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ $(tr_text MULTITEST_DONE)${NC}"
        echo
        echo -e "${CYAN}Запуск multitest...${NC}"
        sleep 1
        if [ -x /usr/local/bin/multitest ]; then
            /usr/local/bin/multitest
        else
            echo -e "${YELLOW}⚠️  'multitest' не найден. Выполните: multitest${NC}"
        fi
    else
        echo -e "${RED}❌ $(tr_text MULTITEST_FAIL)${NC}"
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
        echo -e "  ${YELLOW}3)${NC} $(tr_text SUB_MULTITEST)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice

        case $choice in
            1) show_banner; install_egames_remnawave ;;
            2) show_banner; install_reshala ;;
            3) show_banner; install_multitest ;;
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
#                     СИСТЕМНЫЙ ДАШБОРД
# ══════════════════════════════════════════════════════════════════

# Кэш для медленных сетевых запросов (живёт в рамках сессии)
_DASH_CACHE_INIT=0
_DASH_EXT_IP=""
_DASH_PING=""
_DASH_VIRT=""

show_dashboard() {
    clear

    # ── Сбор данных ──
    local os_name kernel uptime_str users_count
    local cpu_model cpu_cores cpu_pct
    local ram_pct ram_used_g ram_total_g
    local disk_pct disk_used disk_total disk_type lang_display

    # OS / Kernel
    if [ -f /etc/os-release ]; then
        os_name=$(. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-Linux}")
    else
        os_name="$(uname -s)"
    fi
    kernel=$(uname -r | cut -d'-' -f1)

    # Аптайм + активные сессии
    uptime_str=$(uptime -p 2>/dev/null | sed 's/^up //' || echo "N/A")
    users_count=$(who 2>/dev/null | wc -l || echo "1")

    # Виртуализация (кэш на сессию)
    if [ -z "$_DASH_VIRT" ]; then
        if command -v systemd-detect-virt >/dev/null 2>&1; then
            local _vt; _vt=$(systemd-detect-virt 2>/dev/null || echo "unknown")
            case "$_vt" in
                kvm|qemu)  _DASH_VIRT="KVM (Честное железо)" ;;
                lxc)       _DASH_VIRT="Container (LXC)" ;;
                openvz)    _DASH_VIRT="Container (OpenVZ)" ;;
                none)      _DASH_VIRT="Физический сервер" ;;
                *)         _DASH_VIRT="${_vt}" ;;
            esac
        else
            _DASH_VIRT="N/A"
        fi
    fi

    # CPU
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null \
        | sed 's/.*: //;s/(R)//g;s/(TM)//g;s/  */ /g;s/ @.*//;s/^ //;s/ $//' \
        || echo "N/A")
    cpu_cores=$(nproc 2>/dev/null || echo "1")
    local _load; _load=$(cut -d' ' -f1 /proc/loadavg 2>/dev/null || echo "0")
    cpu_pct=$(awk "BEGIN{v=($_load/${cpu_cores:-1})*100;if(v>100)v=100;printf\"%d\",v}" 2>/dev/null || echo "0")

    # RAM
    ram_pct=0; ram_used_g="?"; ram_total_g="?"
    if command -v free >/dev/null 2>&1; then
        local _rtotal _rused
        _rtotal=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}')
        _rused=$(free -m  2>/dev/null | awk '/^Mem:/{print $3}')
        ram_pct=$(( _rused * 100 / (_rtotal > 0 ? _rtotal : 1) ))
        ram_total_g=$(awk "BEGIN{printf\"%.1f\",${_rtotal:-0}/1024}")
        ram_used_g=$(awk  "BEGIN{printf\"%.1f\",${_rused:-0}/1024}")
    fi

    # Диск + тип
    disk_used=$(df -h / 2>/dev/null | awk 'NR==2{print $3}' || echo "?")
    disk_total=$(df -h / 2>/dev/null | awk 'NR==2{print $2}' || echo "?")
    disk_pct=$(df / 2>/dev/null | awk 'NR==2{gsub(/%/,"",$5);print $5}' || echo "0")
    disk_pct=${disk_pct:-0}
    disk_type="HDD"
    local _md; _md=$(df / 2>/dev/null | awk 'NR==2{print $1}' | sed 's|/dev/||;s/[0-9]*$//;s/p[0-9]*$//')
    [ -f "/sys/block/${_md}/queue/rotational" ] && \
        [ "$(cat "/sys/block/${_md}/queue/rotational" 2>/dev/null)" = "0" ] && disk_type="SSD"
    [[ "$_md" == *nvme* ]] && disk_type="NVMe"

    # Внешний IP + пинг (кэш на сессию, чтобы не долбить ifconfig.me)
    if [ "${_DASH_CACHE_INIT:-0}" -eq 0 ]; then
        _DASH_EXT_IP=$(curl -s --connect-timeout 3 -4 ifconfig.me 2>/dev/null \
            || curl -s --connect-timeout 3 https://api.ipify.org 2>/dev/null \
            || hostname -I 2>/dev/null | awk '{print $1}')
        local _p; _p=$(ping -c1 -W1 8.8.8.8 2>/dev/null | grep -oE 'time=[0-9.]+' | cut -d= -f2)
        [ -n "$_p" ] && _DASH_PING="${_p} ms ⚡" || _DASH_PING="OFFLINE ❌"
        _DASH_CACHE_INIT=1
    fi

    # Язык
    [ "$LANG_SET" = "ru" ] && lang_display="Русский" || lang_display="English"

    # ── Прогресс-бар: _pbar <pct> [width=20] ──
    _pbar() {
        local pct=${1:-0} w=${2:-20}
        local filled=$(( pct * w / 100 ))
        local empty=$(( w - filled ))
        local col i
        if   [ "$pct" -ge 90 ]; then col=$RED
        elif [ "$pct" -ge 70 ]; then col=$YELLOW
        else                          col=$GREEN
        fi
        local b="${col}["
        for ((i=0; i<filled; i++)); do b+="▓"; done
        for ((i=0; i<empty;  i++)); do b+="░"; done
        b+="]${NC}"
        echo -e "$b"
    }

    local cpu_bar ram_bar disk_bar
    cpu_bar=$(_pbar "$cpu_pct")
    ram_bar=$(_pbar "$ram_pct")
    disk_bar=$(_pbar "$disk_pct")

    # ── Отрисовка ──
    echo
    echo -e "  ${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${BOLD}${CYAN}      🚀  REMNAWAVE-SCRIPTS${NC}                 ${GREEN}v${VERSION}${NC}"
    echo -e "  ${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo

    echo -e "  ${DIM}─── [ СИСТЕМА ] ──────────────────────────────────────────${NC}"
    echo -e "  ${CYAN}ОС / Ядро      ${NC}: $os_name ${DIM}($kernel)${NC}"
    echo -e "  ${CYAN}Аптайм         ${NC}: $uptime_str ${DIM}(Сессий: $users_count)${NC}"
    echo -e "  ${CYAN}Виртуалка      ${NC}: $_DASH_VIRT"
    echo -e "  ${CYAN}IP Адрес       ${NC}: ${YELLOW}${_DASH_EXT_IP}${NC} ${DIM}(ping 8.8.8.8: ${_DASH_PING})${NC}"
    echo

    echo -e "  ${DIM}─── [ ЖЕЛЕЗО ] ───────────────────────────────────────────${NC}"
    echo -e "  ${CYAN}CPU            ${NC}: ${cpu_model:0:40} ${DIM}[${cpu_cores} vCPU]${NC}"
    echo -e "  ${CYAN}Загрузка CPU   ${NC}: ${cpu_bar} ${BOLD}${cpu_pct}%${NC}"
    echo -e "  ${CYAN}Память (RAM)   ${NC}: ${ram_bar} ${BOLD}${ram_pct}%${NC} ${DIM}(${ram_used_g}G / ${ram_total_g}G)${NC}"
    echo -e "  ${CYAN}Диск (${disk_type})    ${NC}: ${disk_bar} ${BOLD}${disk_pct}%${NC} ${DIM}(${disk_used} / ${disk_total})${NC}"
    echo

    echo -e "  ${DIM}─── [ СТАТУС ] ───────────────────────────────────────────${NC}"
    echo -e "  ${CYAN}rw-scripts     ${NC}: ${GREEN}v${VERSION}${NC}"
    echo -e "  ${CYAN}Язык           ${NC}: $lang_display"
    echo
}

# ══════════════════════════════════════════════════════════════════
#                      БЕЛЫЙ СПИСОК IP
# ══════════════════════════════════════════════════════════════════

WHITELIST_FILE="$DATA_DIR/whitelist.txt"

_wl_init() {
    [ -f "$WHITELIST_FILE" ] || printf "# RW-Scripts IP Whitelist\n# Формат: IP # Комментарий\n" > "$WHITELIST_FILE"
}

_wl_get_ips() {
    _wl_init
    grep -v '^\s*#' "$WHITELIST_FILE" 2>/dev/null | grep -v '^\s*$' | awk '{print $1}'
}

_wl_sync_ufw() {
    local ip="$1" action="$2"
    local firewall; firewall=$(detect_firewall)
    case $firewall in
        ufw)
            if [ "$action" = "add" ]; then
                sudo ufw allow from "$ip" to any comment "rw-whitelist" &>/dev/null
            else
                sudo ufw delete allow from "$ip" to any &>/dev/null
            fi ;;
        firewalld)
            if [ "$action" = "add" ]; then
                sudo firewall-cmd --permanent --add-rich-rule="rule family=ipv4 source address=$ip accept" &>/dev/null
            else
                sudo firewall-cmd --permanent --remove-rich-rule="rule family=ipv4 source address=$ip accept" &>/dev/null
            fi
            sudo firewall-cmd --reload &>/dev/null ;;
        iptables)
            if [ "$action" = "add" ]; then
                sudo iptables -I INPUT -s "$ip" -j ACCEPT 2>/dev/null
            else
                sudo iptables -D INPUT -s "$ip" -j ACCEPT 2>/dev/null
            fi ;;
    esac
}

wl_add_ip() {
    local ip="$1" comment="${2:-Добавлен вручную}"
    _wl_init
    if grep -q "^${ip}" "$WHITELIST_FILE" 2>/dev/null; then
        echo -e "${YELLOW}IP $ip уже в белом списке.${NC}"
        return 0
    fi
    echo "${ip} # ${comment}" >> "$WHITELIST_FILE"
    _wl_sync_ufw "$ip" "add"
    echo -e "${GREEN}✅ IP $ip добавлен и разрешён в firewall.${NC}"
}

wl_remove_ip() {
    local ip="$1"
    _wl_init
    if ! grep -q "^${ip}" "$WHITELIST_FILE" 2>/dev/null; then
        echo -e "${RED}IP $ip не найден в белом списке.${NC}"
        return 1
    fi
    sed -i "/^${ip}/d" "$WHITELIST_FILE"
    _wl_sync_ufw "$ip" "remove"
    echo -e "${GREEN}✅ IP $ip удалён из белого списка и firewall.${NC}"
}

submenu_whitelist() {
    while true; do
        show_banner
        print_submenu_header "🛡️  Белый список IP"

        _wl_init
        local ips; mapfile -t ips < <(_wl_get_ips)
        local count=${#ips[@]}

        if [ "$count" -gt 0 ]; then
            echo -e "  ${DIM}─── Доверенные IP ($count) ──────────────────────────────────${NC}"
            local i=1
            while IFS= read -r line; do
                [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
                local _ip _cmt
                _ip=$(echo "$line" | awk '{print $1}')
                _cmt=$(echo "$line" | sed 's/^[^ ]* *# *//')
                echo -e "  ${GREEN}$i)${NC} ${CYAN}${_ip}${NC}  ${DIM}${_cmt}${NC}"
                ((i++))
            done < "$WHITELIST_FILE"
            echo
        else
            echo -e "  ${YELLOW}Список пуст. Добавьте IP для автоматического разрешения в firewall.${NC}"
            echo
        fi

        local fw; fw=$(detect_firewall)
        echo -e "  ${DIM}Активный firewall: ${CYAN}${fw}${NC}"
        echo
        echo -e "  ${YELLOW}1)${NC} ➕ Добавить IP"
        echo -e "  ${YELLOW}2)${NC} ➖ Удалить IP"
        echo -e "  ${YELLOW}3)${NC} 🔍 Определить IP текущей сессии"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice

        case $choice in
            1)
                show_banner
                read -rp "Введите IP адрес: " new_ip
                [ -z "$new_ip" ] && continue
                read -rp "Комментарий (Enter — пропустить): " cmt
                wl_add_ip "$new_ip" "${cmt:-Добавлен вручную}"
                read -rp "$(tr_text PRESS_ENTER)"
                ;;
            2)
                show_banner
                if [ "$count" -eq 0 ]; then
                    echo -e "${YELLOW}Список пуст.${NC}"
                    read -rp "$(tr_text PRESS_ENTER)"; continue
                fi
                read -rp "Введите IP для удаления: " del_ip
                [ -n "$del_ip" ] && wl_remove_ip "$del_ip"
                read -rp "$(tr_text PRESS_ENTER)"
                ;;
            3)
                show_banner
                local my_ip
                my_ip=$(who am i 2>/dev/null | awk '{print $NF}' | tr -d '()')
                [ -z "$my_ip" ] && my_ip=$(curl -s --connect-timeout 3 ifconfig.me 2>/dev/null)
                if [ -n "$my_ip" ]; then
                    echo -e "${GREEN}Ваш текущий IP: ${CYAN}${my_ip}${NC}"
                    echo
                    read -rp "Добавить в белый список? (y/n): " ans
                    [[ "$ans" =~ ^[YyДд]$ ]] && wl_add_ip "$my_ip" "Auto-detected"
                else
                    echo -e "${RED}Не удалось определить IP.${NC}"
                fi
                read -rp "$(tr_text PRESS_ENTER)"
                ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ══════════════════════════════════════════════════════════════════
#                      ОЧИСТКА СИСТЕМЫ
# ══════════════════════════════════════════════════════════════════

_pkg_install() {
    for pkg in "$@"; do
        if ! command -v "$pkg" >/dev/null 2>&1 && ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo -e "${BLUE}📦 Устанавливаю $pkg...${NC}"
            sudo apt-get install -y "$pkg" &>/dev/null \
                || sudo apt install -y "$pkg" &>/dev/null \
                || true
        fi
    done
}

_clean_get_free() { df -k / | awk 'NR==2{print $4}'; }

_clean_human() {
    local kb=$1
    if (( kb > 1048576 )); then awk "BEGIN{printf\"%.1f GB\",${kb}/1048576}"
    elif (( kb > 1024 ));  then awk "BEGIN{printf\"%.1f MB\",${kb}/1024}"
    else echo "${kb} KB"; fi
}

_clean_run() {
    local title=$1; shift
    local before; before=$(_clean_get_free)
    echo -e "${BLUE}──────────────────────────────${NC}"
    echo -e "${CYAN}▶ $title${NC}"
    echo -e "${BLUE}──────────────────────────────${NC}"
    "$@"
    local after; after=$(_clean_get_free)
    local diff=$(( after - before ))
    echo
    if (( diff > 0 )); then
        echo -e "${GREEN}✅ Освобождено: $(_clean_human $diff)${NC}"
    else
        echo -e "${YELLOW}ℹ️  Мусора не найдено.${NC}"
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

_do_clean_apt() {
    echo -e "${BLUE}Очистка APT кэша...${NC}"
    sudo apt-get autoremove -y 2>/dev/null
    sudo apt-get clean -y 2>/dev/null
    sudo apt-get autoclean -y 2>/dev/null
    local ookla="/etc/apt/sources.list.d/ookla_speedtest-cli.list"
    [ -f "$ookla" ] && sudo rm -f "$ookla" "$ookla.save" \
        && echo -e "${YELLOW}Удалён сломанный репозиторий Ookla.${NC}"
}

_do_clean_journal() {
    echo -e "${BLUE}Очистка системных логов (journald)...${NC}"
    sudo journalctl --vacuum-time=3d 2>/dev/null
    sudo journalctl --vacuum-size=100M 2>/dev/null
}

_do_clean_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${YELLOW}$(tr_text CLEAN_NO_DOCKER)${NC}"; return
    fi
    echo -e "${BLUE}Очистка Docker (system prune)...${NC}"
    sudo docker system prune -a --volumes -f
}

_do_clean_tmp() {
    echo -e "${BLUE}Очистка /tmp и кэша пользователя...${NC}"
    sudo rm -rf /tmp/* /var/tmp/* 2>/dev/null || true
    rm -rf ~/.cache/* 2>/dev/null || true
    echo -e "${GREEN}Временные файлы удалены.${NC}"
}

_do_clean_snap() {
    if ! command -v snap >/dev/null 2>&1; then
        echo -e "${YELLOW}$(tr_text CLEAN_NO_SNAP)${NC}"; return
    fi
    echo -e "${BLUE}Очистка старых Snap-пакетов...${NC}"
    sudo snap set system refresh.retain=2 2>/dev/null || true
    while read -r snapname revision; do
        [ -n "$snapname" ] && sudo snap remove "$snapname" --revision="$revision" 2>/dev/null
    done < <(snap list --all 2>/dev/null | awk '/disabled/{print $1,$3}')
}

_do_clean_all() {
    _do_clean_journal
    _do_clean_apt
    _do_clean_docker
    _do_clean_tmp
    _do_clean_snap
}

_disk_inspector() {
    local dir=$1 mode=$2
    while true; do
        show_banner
        print_submenu_header "📁 $dir"
        echo
        [ "$mode" = "block" ] && echo -e "  ${RED}⚠️  Только просмотр! Удаление может сломать систему.${NC}" && echo
        local i=1
        declare -a _di_paths=()
        while read -r line; do
            local sz; sz=$(echo "$line" | awk '{print $1}')
            local fp; fp=$(echo "$line" | cut -f2-)
            local nm; nm=$(basename "$fp")
            if [ -d "$fp" ]; then
                echo -e "  ${YELLOW}$i)${NC} 📁 ${CYAN}$(printf "%-8s" "$sz")${NC} $nm/"
            else
                echo -e "  ${YELLOW}$i)${NC} 📄 ${GREEN}$(printf "%-8s" "$sz")${NC} $nm"
            fi
            _di_paths[$i]="$fp"
            ((i++))
        done < <(du -sh "$dir"/* 2>/dev/null | sort -hr | head -15)
        [ $i -eq 1 ] && echo -e "  ${YELLOW}Пусто или нет доступа.${NC}"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "Номер (0 = назад): " sel
        [ "$sel" = "0" ] || [ -z "$sel" ] && return
        if [[ "$sel" =~ ^[0-9]+$ ]] && [ -n "${_di_paths[$sel]:-}" ]; then
            local target="${_di_paths[$sel]}"
            if [ -d "$target" ]; then
                _disk_inspector "$target" "$mode"
            elif [ -f "$target" ]; then
                show_banner
                print_submenu_header "📄 $(basename "$target")"
                echo -e "  Размер: ${YELLOW}$(du -sh "$target" | awk '{print $1}')${NC}"
                echo
                echo -e "  ${YELLOW}1)${NC} 👀 Последние 50 строк"
                [ "$mode" != "block" ] && echo -e "  ${YELLOW}2)${NC} ${RED}🗑️  Удалить / очистить${NC}"
                echo
                echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
                echo
                read -rp "> " fsel
                case $fsel in
                    1) clear; tail -n 50 "$target" 2>/dev/null || echo -e "${RED}Бинарный файл.${NC}"
                       read -rp "$(tr_text PRESS_ENTER)" ;;
                    2) [ "$mode" != "block" ] && {
                           if [ "$mode" = "truncate" ]; then
                               > "$target"; echo -e "${GREEN}✅ Файл очищен.${NC}"
                           else
                               sudo rm -f "$target"; echo -e "${GREEN}✅ Файл удалён.${NC}"
                           fi
                           read -rp "$(tr_text PRESS_ENTER)"; return; } ;;
                esac
            fi
        fi
    done
}

_disk_analyzer() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text CLEAN_DISK_ANALY)"
        echo
        echo -e "  ${YELLOW}1)${NC} 📚 /var/log                ${DIM}(логи — очистка)${NC}"
        echo -e "  ${YELLOW}2)${NC} 🐳 /var/lib/docker         ${DIM}(Docker — только просмотр)${NC}"
        echo -e "  ${YELLOW}3)${NC} 📦 /var/cache/apt          ${DIM}(APT — удаление)${NC}"
        echo -e "  ${YELLOW}4)${NC} 🗑️  /tmp                    ${DIM}(временные — удаление)${NC}"
        echo -e "  ${YELLOW}5)${NC} 🌐 /opt/remnawave           ${DIM}(панель — только просмотр)${NC}"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        case $choice in
            1) _disk_inspector "/var/log"        "truncate" ;;
            2) _disk_inspector "/var/lib/docker" "block"    ;;
            3) _disk_inspector "/var/cache/apt"  "rm"       ;;
            4) _disk_inspector "/tmp"             "rm"       ;;
            5) _disk_inspector "/opt/remnawave"  "block"    ;;
            0) return ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

submenu_cleaner() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_CLEANER)"
        echo -e "  ${DIM}Свободно: ${GREEN}$(_clean_human $(_clean_get_free))${NC}"
        echo
        echo -e "  ${YELLOW}1)${NC} $(tr_text CLEAN_ALL)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text CLEAN_APT)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text CLEAN_JOURNAL)"
        echo -e "  ${YELLOW}4)${NC} $(tr_text CLEAN_DOCKER)"
        echo -e "  ${YELLOW}5)${NC} $(tr_text CLEAN_TMP)"
        echo -e "  ${YELLOW}6)${NC} $(tr_text CLEAN_SNAP)"
        echo -e "  ${DIM}──────────────────────────────${NC}"
        echo -e "  ${YELLOW}7)${NC} $(tr_text CLEAN_DISK_ANALY)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        case $choice in
            1) _clean_run "ПОЛНАЯ УБОРКА"  _do_clean_all    ;;
            2) _clean_run "APT"            _do_clean_apt    ;;
            3) _clean_run "ЖУРНАЛЫ"        _do_clean_journal ;;
            4) _clean_run "DOCKER"         _do_clean_docker ;;
            5) _clean_run "/TMP"           _do_clean_tmp    ;;
            6) _clean_run "SNAP"           _do_clean_snap   ;;
            7) _disk_analyzer ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ══════════════════════════════════════════════════════════════════
#                  УПРАВЛЕНИЕ ПАМЯТЬЮ И SWAP
# ══════════════════════════════════════════════════════════════════

_mem_swap_status() {
    local swp; swp=$(free -m 2>/dev/null | awk '/^Swap:/{print $2}')
    local has_zram; has_zram=$(lsblk 2>/dev/null | grep -i zram)
    local has_file; has_file=$(swapon --show --noheadings 2>/dev/null | grep -i swapfile)
    if [ -n "$has_zram" ] && [ -n "$has_file" ]; then
        echo -e "${GREEN}[ГИБРИД: ZRAM + Disk Swap]${NC}"
    elif [ -n "$has_zram" ]; then
        echo -e "${GREEN}[ZRAM: ${swp} MB]${NC}"
    elif [ -n "$swp" ] && [ "$swp" != "0" ]; then
        echo -e "${YELLOW}[Disk Swap: ${swp} MB]${NC}"
    else
        echo -e "${RED}[ВЫКЛЮЧЕН]${NC}"
    fi
}

_mem_show_status() {
    show_banner
    print_submenu_header "$(tr_text MEM_SHOW_STATUS)"
    local mt mu mc ma st su sf
    mt=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}')
    mu=$(free -m 2>/dev/null | awk '/^Mem:/{print $3}')
    mc=$(free -m 2>/dev/null | awk '/^Mem:/{print $6}')
    ma=$(free -m 2>/dev/null | awk '/^Mem:/{print $7}')
    st=$(free -m 2>/dev/null | awk '/^Swap:/{print $2}')
    su=$(free -m 2>/dev/null | awk '/^Swap:/{print $3}')
    sf=$(free -m 2>/dev/null | awk '/^Swap:/{print $4}')
    echo -e "  ${CYAN}💻 Оперативная память (RAM):${NC}"
    echo -e "    └─ Всего:        ${GREEN}${mt} MB${NC}"
    echo -e "    └─ Используется: ${YELLOW}${mu} MB${NC}"
    echo -e "    └─ Кэш/Буферы:  ${BLUE}${mc} MB${NC}"
    echo -e "    └─ Свободно:     ${GREEN}${ma} MB${NC}"
    echo
    echo -e "  ${CYAN}💽 Файл подкачки (ZRAM / Swap):${NC}"
    if [ "${st:-0}" = "0" ]; then
        echo -e "    └─ ${RED}ВЫКЛЮЧЕН (рекомендуется включить ZRAM!)${NC}"
    else
        lsblk 2>/dev/null | grep -q zram \
            && echo -e "    └─ Тип: ${GREEN}ZRAM (сжатие в ОЗУ)${NC}" \
            || echo -e "    └─ Тип: ${YELLOW}Disk Swap${NC}"
        echo -e "    └─ Выделено:     ${GREEN}${st} MB${NC}"
        echo -e "    └─ Используется: ${RED}${su} MB${NC}"
        echo -e "    └─ Свободно:     ${GREEN}${sf} MB${NC}"
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

_mem_show_instructions() {
    show_banner
    print_submenu_header "$(tr_text MEM_INSTRUCTIONS)"
    echo -e "  ${CYAN}${BOLD}ZRAM vs Disk Swap:${NC}"
    echo -e "  ${GREEN}ZRAM${NC} — сжатие в ОЗУ, скорость = RAM. Идеален для VPN."
    echo -e "       Обязателен для серверов 1-2 ГБ!"
    echo -e "  ${YELLOW}Disk Swap${NC} — в 10-50× медленнее ZRAM. Только если ОЗУ < 512 МБ."
    echo
    echo -e "  ${CYAN}${BOLD}Лимиты памяти в docker-compose.yml (блок remnanode):${NC}"
    echo
    echo -e "  ${BOLD}▶ Сервер 1 ГБ RAM:${NC}"
    echo -e "${CYAN}    environment:
      - NODE_OPTIONS=--max-old-space-size=256
    deploy:
      resources:
        limits:
          memory: 768M${NC}"
    echo
    echo -e "  ${BOLD}▶ Сервер 2 ГБ RAM:${NC}"
    echo -e "${CYAN}    environment:
      - NODE_OPTIONS=--max-old-space-size=512
    deploy:
      resources:
        limits:
          memory: 1536M${NC}"
    echo
    echo -e "  ${BOLD}▶ Сервер 4+ ГБ RAM:${NC}"
    echo -e "${CYAN}    environment:
      - NODE_OPTIONS=--max-old-space-size=1024
    deploy:
      resources:
        limits:
          memory: 3072M${NC}"
    echo
    echo -e "  ${YELLOW}После изменений: docker compose down && docker compose up -d${NC}"
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

_mem_install_hybrid() {
    echo -e "${BLUE}Настройка гибридной памяти (ZRAM 50% + Disk Swap 2GB)...${NC}"
    _pkg_install zram-tools bc
    printf "ALGO=lz4\nPERCENT=50\nPRIORITY=100\n" | sudo tee /etc/default/zramswap >/dev/null
    sudo systemctl restart zramswap >/dev/null 2>&1
    sudo systemctl enable zramswap >/dev/null 2>&1
    if [ ! -f /swapfile ]; then
        echo -e "${BLUE}Создание Disk Swap 2GB (резервная страховка)...${NC}"
        sudo fallocate -l 2G /swapfile 2>/dev/null \
            || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile >/dev/null 2>&1
        sudo swapon -p -2 /swapfile 2>/dev/null || sudo swapon /swapfile
        grep -qE '^/swapfile\s' /etc/fstab \
            || echo '/swapfile none swap sw,pri=-2 0 0' | sudo tee -a /etc/fstab >/dev/null
    fi
    echo -e "${GREEN}✅ Гибридная память: ZRAM (prio 100) + Swap (prio -2).${NC}"
}

_mem_install_zram() {
    local pct=$1
    echo -e "${BLUE}Установка ZRAM (${pct}%)...${NC}"
    sudo swapoff -a 2>/dev/null || true
    sudo rm -f /swapfile 2>/dev/null
    sudo sed -i '/^\/swapfile/d' /etc/fstab 2>/dev/null
    _pkg_install zram-tools bc
    printf "ALGO=lz4\nPERCENT=%s\nPRIORITY=100\n" "$pct" | sudo tee /etc/default/zramswap >/dev/null
    sudo systemctl restart zramswap >/dev/null 2>&1
    sudo systemctl enable zramswap >/dev/null 2>&1
    echo -e "${GREEN}✅ ZRAM ${pct}% активирован!${NC}"
}

_mem_install_swap() {
    local sz=$1
    echo -e "${BLUE}Создание Disk Swap ${sz}GB...${NC}"
    sudo systemctl stop zramswap 2>/dev/null || true
    sudo apt-get remove --purge zram-tools -y >/dev/null 2>&1 || true
    sudo swapoff -a 2>/dev/null || true
    sudo rm -f /swapfile 2>/dev/null
    sudo fallocate -l "${sz}G" /swapfile \
        || sudo dd if=/dev/zero of=/swapfile bs=1M count=$(( sz * 1024 )) status=none
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile >/dev/null 2>&1
    sudo swapon /swapfile
    grep -qE '^/swapfile\s' /etc/fstab \
        || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
    echo -e "${GREEN}✅ Disk Swap ${sz}GB создан!${NC}"
}

_mem_remove_all() {
    echo -e "${BLUE}Удаление ZRAM и Disk Swap...${NC}"
    sudo systemctl stop zramswap 2>/dev/null || true
    sudo systemctl disable zramswap 2>/dev/null || true
    sudo apt-get remove --purge zram-tools -y >/dev/null 2>&1 || true
    sudo swapoff -a 2>/dev/null || true
    sudo rm -f /swapfile 2>/dev/null
    sudo sed -i '/^\/swapfile/d' /etc/fstab 2>/dev/null
    echo -e "${GREEN}✅ ZRAM и Swap полностью удалены.${NC}"
}

submenu_memory() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_MEMORY)"

        local ram_kb; ram_kb=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')
        local ram_mb=$(( ${ram_kb:-0} / 1024 ))
        local ram_gb=$(( (ram_mb + 512) / 1024 ))
        local rec_zram rec_swap
        if   [ "$ram_mb" -le 1024 ]; then rec_zram=60; rec_swap=2
        elif [ "$ram_mb" -le 2048 ]; then rec_zram=50; rec_swap=2
        elif [ "$ram_mb" -le 4096 ]; then rec_zram=40; rec_swap=4
        else                              rec_zram=25; rec_swap=4; fi

        echo -e "  ${DIM}RAM: ${GREEN}${ram_gb} GB (${ram_mb} MB)${NC}  |  Swap: $(_mem_swap_status)"
        echo
        echo -e "  ${YELLOW}1)${NC} $(tr_text MEM_HYBRID)"
        echo -e "     ${DIM}└ Рекомендовано: ZRAM ${rec_zram}% + Swap ${rec_swap}GB${NC}"
        echo -e "  ${YELLOW}2)${NC} $(tr_text MEM_ZRAM_ONLY)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text MEM_SWAP_ONLY)"
        echo -e "  ${DIM}──────────────────────────────${NC}"
        echo -e "  ${YELLOW}4)${NC} $(tr_text MEM_REMOVE_ALL)"
        echo -e "  ${YELLOW}5)${NC} $(tr_text MEM_SHOW_STATUS)"
        echo -e "  ${YELLOW}6)${NC} $(tr_text MEM_INSTRUCTIONS)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        case $choice in
            1) show_banner; _mem_install_hybrid; read -rp "$(tr_text PRESS_ENTER)" ;;
            2) show_banner
               echo -e "${YELLOW}$(tr_text MEM_ZRAM_PERCENT)${NC}"
               read -rp "> " pct; pct=${pct:-60}
               [[ "$pct" =~ ^[0-9]+$ ]] || { echo -e "${RED}$(tr_text ERR_NUMBER)${NC}"; sleep 1; continue; }
               _mem_install_zram "$pct"; read -rp "$(tr_text PRESS_ENTER)" ;;
            3) show_banner
               echo -e "${YELLOW}$(tr_text MEM_SWAP_SIZE)${NC}"
               read -rp "> " sz; sz=${sz:-2}
               [[ "$sz" =~ ^[0-9]+$ ]] || { echo -e "${RED}$(tr_text ERR_NUMBER)${NC}"; sleep 1; continue; }
               _mem_install_swap "$sz"; read -rp "$(tr_text PRESS_ENTER)" ;;
            4) show_banner; _mem_remove_all; read -rp "$(tr_text PRESS_ENTER)" ;;
            5) _mem_show_status ;;
            6) _mem_show_instructions ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ══════════════════════════════════════════════════════════════════
#                    REALITY TLS SCANNER
# ══════════════════════════════════════════════════════════════════

SCANNER_DIR="/opt/RealityTLScanner"
SCANNER_BIN="$SCANNER_DIR/RealiTLScanner"
SCANNER_GEO="$SCANNER_DIR/Country.mmdb"
SCANNER_LIST="$SCANNER_DIR/targets.txt"

_scan_install() {
    export PATH=/usr/local/go/bin:$PATH
    mkdir -p "$SCANNER_DIR/reports" 2>/dev/null

    if [ ! -f "$SCANNER_BIN" ]; then
        echo -e "${YELLOW}Устанавливаю RealiTLScanner (нужен Go для компиляции)...${NC}"
        _pkg_install git curl wget

        local go_arch="amd64"
        [ "$(uname -m)" = "aarch64" ] && go_arch="arm64"
        local go_ver
        go_ver=$(curl -4 -fsSL --connect-timeout 20 'https://go.dev/VERSION?m=text' 2>/dev/null | head -1)
        [[ "$go_ver" == go1.* ]] || go_ver="go1.22.6"
        echo -e "${BLUE}Загрузка Go ${go_ver} (${go_arch})...${NC}"
        curl -4 -sL --connect-timeout 120 \
            -o /tmp/go.tar.gz \
            "https://go.dev/dl/${go_ver}.linux-${go_arch}.tar.gz" || {
            echo -e "${RED}❌ Не удалось загрузить Go.${NC}"; return 1; }
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        export PATH=/usr/local/go/bin:$PATH

        local src="$SCANNER_DIR/src"
        rm -rf "$src"
        git clone https://github.com/xtls/RealiTLScanner.git "$src" || {
            echo -e "${RED}❌ Не удалось клонировать репозиторий.${NC}"; return 1; }
        echo -e "${CYAN}Компиляция...${NC}"
        cd "$src" || return 1
        go build -o "$SCANNER_BIN" && chmod +x "$SCANNER_BIN"
        rm -rf "$src"
        cd - >/dev/null
        [ -f "$SCANNER_BIN" ] \
            && echo -e "${GREEN}✅ RealiTLScanner установлен!${NC}" \
            || { echo -e "${RED}❌ Ошибка компиляции.${NC}"; return 1; }
    fi

    if [ ! -f "$SCANNER_GEO" ]; then
        echo -e "${BLUE}Загрузка GeoIP базы...${NC}"
        curl -sL --connect-timeout 30 \
            -o "$SCANNER_GEO" \
            "https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb" \
            || echo -e "${YELLOW}⚠️ Не удалось загрузить GeoIP базу.${NC}"
    fi
}

_scan_ensure() {
    if [ ! -f "$SCANNER_BIN" ]; then
        echo -e "${YELLOW}Сканер не установлен.${NC}"
        read -rp "Установить сейчас? (y/n): " ans
        [[ "$ans" =~ ^[YyДд]$ ]] || return 1
        _scan_install || return 1
    fi
    export PATH=/usr/local/go/bin:$PATH
    return 0
}

_scan_analyze() {
    local file=$1
    [ ! -f "$file" ] && return
    local lines; lines=$(wc -l < "$file" 2>/dev/null)
    [ "${lines:-0}" -le 1 ] && echo -e "${YELLOW}Результатов нет.${NC}" && return
    echo -e "${GREEN}🏆 ТОП-10 лучших SNI:${NC}"
    echo -e "${DIM}──────────────────────────────────────────${NC}"
    awk -F, 'NR>1{
        iss=tolower($4); w=9
        if(iss~/google|apple|microsoft/)       w=1
        else if(iss~/digicert|globalsign|sectigo/) w=2
        else if(iss~/cloudflare/)              w=3
        else if(iss~/lets encrypt|zerossl/)    w=4
        if(w<9){ port=($6?$6:"443"); print w"|"$3"|"$1"|"port"|"$5"|"$4 }
    }' "$file" | sort -t'|' -k1,1n | uniq | head -10 | \
    while IFS='|' read -r w dom ip port geo iss; do
        case $w in
            1) echo -e "  💎 ${CYAN}${BOLD}${dom}${NC}" ;;
            2|3) echo -e "  📍 ${GREEN}${dom}${NC}" ;;
            *) echo -e "  🔸 ${dom}" ;;
        esac
        echo -e "     ${DIM}IP: ${ip}  Порт: ${YELLOW}${port}${NC}${DIM}  ГЕО: ${geo}  ${iss}${NC}"
    done
}

_scan_single() {
    _scan_ensure || return
    show_banner
    print_submenu_header "$(tr_text SCAN_SINGLE)"
    echo -e "  ${CYAN}Проверяет конкретный IP/домен на пригодность для Reality-маскировки.${NC}"
    echo
    read -rp "$(tr_text SCAN_TARGET) " target
    [ -z "$target" ] && return
    read -rp "$(tr_text SCAN_PORT) " ports; ports=${ports:-443}

    local scan_target="$target"
    [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && scan_target="${target}/32"

    local ts; ts=$(date +%s)
    local out="$SCANNER_DIR/reports/scan_${ts}.csv"
    echo "ip,feasible,cert-domain,cert-issuer,geo,port" > "$out"
    cd "$SCANNER_DIR" || return

    IFS=',' read -ra _PORT_ARR <<< "${ports// /}"
    trap 'echo -e "\n${YELLOW}Прерывание...${NC}"' INT
    for port in "${_PORT_ARR[@]}"; do
        echo -e "${BLUE}──── Порт ${port} ────${NC}"
        local tmp="$SCANNER_DIR/.tmp_${ts}.csv"
        local log
        log=$("$SCANNER_BIN" -addr "$scan_target" -port "$port" -timeout 5 -v -out "$tmp" 2>&1)
        rm -f "$tmp"
        local found=false
        while IFS= read -r line; do
            if [[ "$line" == *"Connected to target"* ]]; then
                found=true
                local feas ip tls alpn dom iss geo
                feas=$(echo "$line" | grep -oP 'feasible=\K[^ ]+')
                ip=$(echo   "$line" | grep -oP 'ip=\K[^ ]+')
                tls=$(echo  "$line" | grep -oP 'tls=\K[^ "]+' | head -1)
                alpn=$(echo "$line" | grep -oP 'alpn=\K[^ "]+' | head -1)
                dom=$(echo  "$line" | grep -oP 'cert-domain=\K[^ "]+' | head -1)
                iss=$(echo  "$line" | grep -oP 'cert-issuer=\K[^ "]+' | head -1)
                geo=$(echo  "$line" | grep -oP 'geo=\K[^ ]+')
                echo
                echo -e "  🌐 IP:       ${ip:-?}"
                [ "$feas" = "true" ] \
                    && echo -e "  ${GREEN}✅ ПОДХОДИТ ДЛЯ REALITY${NC}" \
                    || echo -e "  ${RED}❌ НЕ ПОДХОДИТ${NC}"
                echo -e "  🔒 TLS:      ${tls:-?}    ⚡ ALPN: ${alpn:-?}"
                echo -e "  📍 Домен:    ${dom:-?}"
                echo -e "  🏢 Издатель: ${iss:-?}    🌍 ГЕО: ${geo:-?}"
                echo
                echo "${ip},${feas},${dom},${iss},${geo},${port}" >> "$out"
            elif [[ "$line" == *"TLS handshake failed"* || "$line" == *"Cannot dial"* ]]; then
                found=true
                echo -e "  ${RED}❌ Соединение не установлено (TLS/connect error).${NC}"
            fi
        done <<< "$log"
        $found || echo -e "  ${YELLOW}⚠️ Нет ответа от ${target}:${port}${NC}"
    done
    trap - INT
    cd - >/dev/null

    local cnt; cnt=$(( $(wc -l < "$out" 2>/dev/null) - 1 ))
    [ "$cnt" -gt 0 ] && echo && _scan_analyze "$out"
    echo
    echo -e "${DIM}Отчёт: $out${NC}"
    read -rp "$(tr_text PRESS_ENTER)"
}

_scan_mass() {
    _scan_ensure || return
    touch "$SCANNER_LIST"
    if [ ! -s "$SCANNER_LIST" ]; then
        show_banner
        print_submenu_header "$(tr_text SCAN_MASS)"
        echo -e "  ${YELLOW}Файл списка пуст: $SCANNER_LIST${NC}"
        echo -e "  ${DIM}Добавьте цели через меню «Список целей».${NC}"
        echo
        read -rp "$(tr_text PRESS_ENTER)"; return
    fi
    show_banner
    print_submenu_header "$(tr_text SCAN_MASS)"
    local total; total=$(grep -c '.' "$SCANNER_LIST" 2>/dev/null || echo 0)
    echo -e "  ${CYAN}Целей в списке: ${YELLOW}$total${NC}"
    echo
    read -rp "$(tr_text SCAN_PORT) " ports; ports=${ports:-443}

    local ts; ts=$(date +%s)
    local out="$SCANNER_DIR/reports/mass_${ts}.csv"
    echo "ip,feasible,cert-domain,cert-issuer,geo,port" > "$out"
    cd "$SCANNER_DIR" || return

    IFS=',' read -ra _PORT_ARR <<< "${ports// /}"
    local done_cnt=0
    trap 'echo -e "\n${YELLOW}Прерывание — сохраняем...${NC}"; break' INT
    while IFS= read -r raw; do
        [ -z "$raw" ] && continue
        local t="$raw"
        [[ "$t" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && t="${t}/32"
        ((done_cnt++))
        echo -ne "\r\033[K${CYAN}[$done_cnt/$total]${NC} ${YELLOW}${raw}${NC}..."
        for port in "${_PORT_ARR[@]}"; do
            local tmp="$SCANNER_DIR/.tmp_${ts}.csv"
            local log
            log=$("$SCANNER_BIN" -addr "$t" -port "$port" -timeout 5 -v -out "$tmp" 2>&1)
            rm -f "$tmp"
            while IFS= read -r line; do
                if [[ "$line" == *"Connected to target"* ]]; then
                    local feas ip dom iss geo
                    feas=$(echo "$line" | grep -oP 'feasible=\K[^ ]+')
                    ip=$(echo   "$line" | grep -oP 'ip=\K[^ ]+')
                    dom=$(echo  "$line" | grep -oP 'cert-domain=\K[^ "]+' | head -1)
                    iss=$(echo  "$line" | grep -oP 'cert-issuer=\K[^ "]+' | head -1)
                    geo=$(echo  "$line" | grep -oP 'geo=\K[^ ]+')
                    echo "${ip},${feas},${dom},${iss},${geo},${port}" >> "$out"
                fi
            done <<< "$log"
        done
    done < "$SCANNER_LIST"
    trap - INT

    echo -e "\r\033[K${GREEN}✅ Готово! (${done_cnt} целей просканировано)${NC}"
    cd - >/dev/null
    echo
    _scan_analyze "$out"
    echo
    echo -e "${DIM}Отчёт: $out${NC}"
    read -rp "$(tr_text PRESS_ENTER)"
}

_scan_manage_list() {
    while true; do
        show_banner
        print_submenu_header "📋 Список целей"
        touch "$SCANNER_LIST"
        local cnt; cnt=$(grep -c '.' "$SCANNER_LIST" 2>/dev/null || echo 0)
        echo -e "  ${DIM}$SCANNER_LIST (${cnt} целей)${NC}"
        echo
        if [ "$cnt" -gt 0 ]; then
            grep -n '.' "$SCANNER_LIST" 2>/dev/null | head -20 | \
                while IFS=: read -r n line; do echo -e "  ${DIM}$n)${NC} $line"; done
            [ "$cnt" -gt 20 ] && echo -e "  ${DIM}... и ещё $(( cnt - 20 )) записей${NC}"
            echo
        fi
        echo -e "  ${YELLOW}1)${NC} ➕ Добавить цель (IP или домен)"
        echo -e "  ${YELLOW}2)${NC} 🗑️  Очистить весь список"
        echo -e "  ${YELLOW}3)${NC} ✏️  Открыть в nano"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        case $choice in
            1) read -rp "IP или домен: " t
               [ -n "$t" ] && echo "$t" >> "$SCANNER_LIST" \
               && echo -e "${GREEN}✅ Добавлено: $t${NC}" && sleep 1 ;;
            2) > "$SCANNER_LIST"; echo -e "${GREEN}✅ Список очищен.${NC}"; sleep 1 ;;
            3) command -v nano >/dev/null 2>&1 && nano "$SCANNER_LIST" \
               || { echo -e "${RED}nano не установлен.${NC}"; sleep 1; } ;;
            0) return ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

_scan_reports() {
    while true; do
        show_banner
        print_submenu_header "📂 Отчёты сканера"
        local rdir="$SCANNER_DIR/reports"
        mkdir -p "$rdir"
        local i=1
        declare -a _rfiles=()
        while IFS= read -r f; do
            local base; base=$(basename "$f")
            local sz; sz=$(du -sh "$f" | awk '{print $1}')
            local rlines; rlines=$(wc -l < "$f" 2>/dev/null)
            echo -e "  ${YELLOW}$i)${NC} ${base} ${DIM}(${sz}, ${rlines} строк)${NC}"
            _rfiles[$i]="$f"; ((i++))
        done < <(ls -t "$rdir"/*.csv 2>/dev/null)
        [ ${#_rfiles[@]} -eq 0 ] && echo -e "  ${YELLOW}Отчётов нет.${NC}"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "Номер для анализа (0 = назад): " sel
        [ "$sel" = "0" ] || [ -z "$sel" ] && return
        if [[ "$sel" =~ ^[0-9]+$ ]] && [ -n "${_rfiles[$sel]:-}" ]; then
            show_banner
            print_submenu_header "📊 $(basename "${_rfiles[$sel]}")"
            _scan_analyze "${_rfiles[$sel]}"
            echo
            read -rp "$(tr_text PRESS_ENTER)"
        fi
    done
}

submenu_scanner() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_SCANNER)"
        echo -e "  ${DIM}Поиск идеальных SNI-доменов для маскировки Reality/VLESS.${NC}"
        local _sc_status
        [ -f "$SCANNER_BIN" ] \
            && _sc_status="${GREEN}✅ Установлен${NC}" \
            || _sc_status="${RED}❌ Не установлен${NC}"
        echo -e "  ${DIM}Статус сканера: $_sc_status${NC}"
        echo
        echo -e "  ${YELLOW}1)${NC} $(tr_text SCAN_SINGLE)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SCAN_MASS)"
        echo -e "  ${YELLOW}3)${NC} 📋 Список целей"
        echo -e "  ${YELLOW}4)${NC} 📂 Отчёты"
        echo -e "  ${DIM}──────────────────────────────${NC}"
        echo -e "  ${YELLOW}5)${NC} 🔧 Установить / переустановить сканер"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        case $choice in
            1) _scan_single ;;
            2) _scan_mass ;;
            3) _scan_manage_list ;;
            4) _scan_reports ;;
            5) show_banner; _scan_install; read -rp "$(tr_text PRESS_ENTER)" ;;
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
        show_dashboard
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
        echo -e "  ${YELLOW}7)${NC} 🛡️  Белый список IP"
        echo -e "  ${YELLOW}8)${NC} $(tr_text GROUP_CLEANER)"
        echo -e "  ${YELLOW}9)${NC} $(tr_text GROUP_MEMORY)"
        echo -e "  ${YELLOW}10)${NC} $(tr_text GROUP_SCANNER)"
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
            7) submenu_whitelist ;;
            8) submenu_cleaner ;;
            9) submenu_memory ;;
            10) submenu_scanner ;;
            0) echo -e "${GREEN}$(tr_text MSG_EXIT)${NC}"; exit 0 ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ====== ЗАПУСК ======
show_main_menu