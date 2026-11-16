# shellcheck shell=bash
# Русский словарь интерфейса: tr_text KEY. Подгружается из scripts.sh.
tr_text() {
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
        SUB_ROLLBACK)     echo "↩️  Откатить последнее обновление" ;;
        SUB_VERIFY)       echo "🔍 Проверить целостность файлов" ;;
        ROLLBACK_NONE)    echo "Предыдущей версии пока нет (она сохраняется при следующем обновлении)." ;;
        ROLLBACK_TARGET)  echo "Предыдущая версия:" ;;
        ROLLBACK_ASK)     echo "Вернуться на предыдущую версию? (y/n)" ;;
        ROLLBACK_BAD)     echo "Сохранённая копия не совпала с контрольными суммами — откат отменён." ;;
        ROLLBACK_FAIL)    echo "Не удалось выполнить откат." ;;
        ROLLBACK_DONE)    echo "Выполнен откат до версии" ;;
        VERIFY_TITLE)     echo "Проверка целостности:" ;;
        VERIFY_NO_SUMS)   echo "Нет сохранённого SHA256SUMS (он записывается при установке и обновлении). Попробуйте: rw-scripts verify --online" ;;
        VERIFY_OK)        echo "Все файлы совпадают с SHA256SUMS" ;;
        VERIFY_BAD)       echo "Часть файлов отличается от SHA256SUMS (повреждены или изменены). Переустановите через install.sh." ;;
        
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
        UPDATE_BAD_HASH)  echo "Контрольная сумма не совпала — обновление отменено. Если релиз только что вышел, повторите через несколько минут." ;;
        UPDATE_NO_HASH)   echo "Не удалось проверить SHA256 (нет SHA256SUMS или sha256sum) — обновление отменено." ;;
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
        SUB_HY2_REMNA)        echo "🔧 Настроить Hysteria2 для ноды (Remnanode)" ;;
        HY2_GROUP_MIHOMO)     echo "── Для ядра Mihomo (отдельный сервер Hysteria2) ──" ;;
        HY2_GROUP_NODE)       echo "── Для ноды Remnawave (Xray-инбаунд) ──" ;;
        HY2R_NO_COMPOSE)      echo "Не найден /opt/remnanode/docker-compose.yml. Remnanode установлен?" ;;
        HY2R_DOMAIN_PROMPT)   echo "Введите домен (сертификат Let's Encrypt уже должен быть выпущен):" ;;
        HY2R_DOMAIN_INVALID)  echo "Неверный домен." ;;
        HY2R_NO_CERT)         echo "Сертификат не найден:" ;;
        HY2R_PORT_PROMPT)     echo "Введите UDP-порт для Hysteria2 (по умолчанию 443):" ;;
        HY2R_NO_VOLUMES)      echo "В docker-compose.yml нет секции 'volumes:'. Добавьте монтирования вручную." ;;
        HY2R_COMPOSE_DONE)    echo "docker-compose.yml обновлён (бэкап: docker-compose.yml.bak)." ;;
        HY2R_HOOK_DONE)       echo "Хук продления сертификата создан." ;;
        HY2R_RESTART_CONFIRM) echo "Перезапустить Remnanode сейчас (docker compose down && up -d)? (y/N)" ;;
        HY2R_RESTART_FAIL)    echo "Не удалось перезапустить Remnanode." ;;
        HY2R_DONE)            echo "Hysteria2 для Remnanode подготовлен!" ;;
        HY2R_XRAY_HINT)       echo "Укажите эти пути к сертификату в Xray-инбаунде (панель Remnawave):" ;;
        HY2R_ALREADY)         echo "Hysteria2 для Remnanode уже настроен." ;;
        HY2R_RECONFIGURE)     echo "Настроить заново? (y/N)" ;;
        SUB_ZAPRET)           echo "🛡️  Установка zapret" ;;
        ZAPRET_INSTALLING)    echo "Устанавливаю zapret..." ;;
        ZAPRET_DONE)          echo "Zapret успешно установлен!" ;;
        ZAPRET_FAIL)          echo "Ошибка при установке zapret." ;;
        SUB_WARP)             echo "☁️  Cloudflare WARP" ;;
        SUB_WARP_INSTALL)     echo "📥 Установка WARP" ;;
        SUB_WARP_STATUS)      echo "📋 Статус WARP" ;;
        SUB_WARP_DISCONNECT)  echo "🛑 Отключить WARP" ;;
        SUB_WARP_CONNECT)     echo "🟢 Включить WARP" ;;
        SUB_WARP_UNINSTALL)   echo "🗑️  Удалить WARP" ;;
        WARP_NOT_INSTALLED)   echo "WARP не установлен. Сначала установите его." ;;
        WARP_STATUS_OK)       echo "WARP подключён" ;;
        WARP_STATUS_BAD)      echo "WARP НЕ подключён" ;;
        WARP_ALREADY_OFF)     echo "WARP уже отключён." ;;
        WARP_ALREADY_ON)      echo "WARP уже подключён." ;;
        WARP_DISCONNECTED)    echo "WARP отключён." ;;
        WARP_CONNECTED)       echo "WARP подключён." ;;
        WARP_UNINSTALL_CONFIRM) echo "Полностью удалить Cloudflare WARP? (y/N)" ;;
        WARP_UNINSTALLING)    echo "Удаляю WARP..." ;;
        WARP_UNINSTALLED)     echo "WARP удалён." ;;
        WARP_CANCELLED)       echo "Отменено." ;;
        WARP_PORT_PROMPT)     echo "Введите порт для WARP прокси (по умолчанию 40000):" ;;
        WARP_PORT_INVALID)    echo "Неверный порт, допустимо 1-65535." ;;
        WARP_ROOT_REQUIRED)   echo "Для установки WARP нужны права root." ;;
        WARP_OS_UNSUPPORTED)  echo "Поддерживаются только Ubuntu и Debian." ;;
        WARP_INSTALLING)      echo "Устанавливаю Cloudflare WARP..." ;;
        WARP_REPO_FAIL)       echo "Не удалось добавить репозиторий Cloudflare." ;;
        WARP_PKG_FAIL)        echo "Не удалось установить пакет cloudflare-warp." ;;
        WARP_CONFIG_FAIL)     echo "Не удалось настроить WARP (регистрация/порт/режим)." ;;
        WARP_CONNECT_FAIL)    echo "Не удалось подключиться к WARP." ;;
        WARP_DONE)            echo "WARP установлен и подключён!" ;;
        WARP_PORT_LABEL)      echo "Порт прокси" ;;
        WARP_IP_LABEL)        echo "Внешний IP" ;;
        WARP_COUNTRY_LABEL)   echo "Страна" ;;
        WARP_CMDS)            echo "Команды управления" ;;
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
        # === ПОДСКАЗКИ ГЛАВНОГО МЕНЮ ===
        HINT_ID_FLAGS)    echo "└ Генерация shorts_id, флаги и названия стран" ;;
        HINT_MONITOR)     echo "└ Свободная память, htop, системная информация" ;;
        HINT_PORTS)       echo "└ Открыть/закрыть порты, UFW / FirewallD / iptables" ;;
        HINT_SETTINGS)    echo "└ Обновление, APT, очистка, память, Scanner, удаление" ;;
        HINT_SERVER)      echo "└ Смена SSH порта, Zapret, Hysteria2, Cloudflare WARP" ;;
        HINT_THIRDPARTY)  echo "└ EGames Remnawave, Reshala, Multitest" ;;
        HINT_CLEANER)     echo "└ APT, Docker, journald, /tmp, Snap, анализатор диска" ;;
        HINT_MEMORY)      echo "└ ZRAM, Disk Swap, гибридный режим, лимиты Docker" ;;
        HINT_SCANNER)     echo "└ SNI для VLESS+Reality, OSINT, массовый пробив" ;;
    esac
}
