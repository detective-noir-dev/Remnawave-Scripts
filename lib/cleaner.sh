#!/bin/bash
# lib/cleaner.sh — Очистка системы и анализ диска
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

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
    $SUDO apt-get autoremove --purge -y 2>/dev/null
    $SUDO apt-get clean -y 2>/dev/null
    $SUDO apt-get autoclean -y 2>/dev/null
    $SUDO find /var/cache/apt -type f \( -name '*.deb' -o -name '*.bin' \) -delete 2>/dev/null || true
    local ookla="/etc/apt/sources.list.d/ookla_speedtest-cli.list"
    [ -f "$ookla" ] && $SUDO rm -f "$ookla" "$ookla.save" \
        && echo -e "${YELLOW}Удалён сломанный репозиторий Ookla.${NC}"
}

_do_clean_journal() {
    echo -e "${BLUE}Очистка системных логов (journald)...${NC}"
    # без rotate vacuum не трогает активный файл журнала
    $SUDO journalctl --rotate 2>/dev/null
    $SUDO journalctl --vacuum-time=3d 2>/dev/null
    $SUDO journalctl --vacuum-size=100M 2>/dev/null
}

_do_clean_logs() {
    echo -e "${BLUE}Очистка /var/log и логов контейнеров...${NC}"
    # архивные и ротированные логи удаляем
    $SUDO find /var/log -type f \( -name '*.gz' -o -name '*.xz' -o -name '*.bz2' -o -name '*.zst'         -o -name '*.old' -o -name '*.[0-9]' \) -delete 2>/dev/null || true
    # живые текстовые логи обнуляем (journal не трогаем — им занимается journalctl)
    $SUDO find /var/log -type f ! -path '/var/log/journal/*' \( -name '*.log' -o -name 'syslog'         -o -name 'messages' -o -name 'btmp' -o -name 'wtmp' -o -name 'lastlog' \)         -exec truncate -s 0 {} + 2>/dev/null || true
    # json-логи Docker-контейнеров (работающим контейнерам truncate безопасен)
    $SUDO find /var/lib/docker/containers -type f -name '*-json.log*'         -exec truncate -s 0 {} + 2>/dev/null || true
    echo -e "${GREEN}Логи очищены.${NC}"
}

_do_clean_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${YELLOW}$(tr_text CLEAN_NO_DOCKER)${NC}"; return
    fi
    echo -e "${BLUE}Очистка Docker (system prune)...${NC}"
    $SUDO docker system prune -a --volumes -f
    $SUDO docker builder prune -a -f 2>/dev/null || true
}

_do_clean_tmp() {
    echo -e "${BLUE}Очистка /tmp и кэша пользователя...${NC}"
    # find -delete, чтобы уходили и скрытые файлы (rm -rf /tmp/* их пропускает)
    $SUDO find /tmp /var/tmp -mindepth 1 -delete 2>/dev/null || true
    rm -rf ~/.cache/* ~/.cache/.[!.]* 2>/dev/null || true
    echo -e "${GREEN}Временные файлы удалены.${NC}"
}

_do_clean_snap() {
    if ! command -v snap >/dev/null 2>&1; then
        echo -e "${YELLOW}$(tr_text CLEAN_NO_SNAP)${NC}"; return
    fi
    echo -e "${BLUE}Очистка старых Snap-пакетов...${NC}"
    $SUDO snap set system refresh.retain=2 2>/dev/null || true
    while read -r snapname revision; do
        [ -n "$snapname" ] && $SUDO snap remove "$snapname" --revision="$revision" 2>/dev/null
    done < <(snap list --all 2>/dev/null | awk '/disabled/{print $1,$3}')
}

_do_clean_all() {
    _do_clean_journal
    _do_clean_logs
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
        done < <($SUDO du -sh "$dir"/* 2>/dev/null | sort -hr | head -15)
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
                    1) clear; $SUDO tail -n 50 "$target" 2>/dev/null || echo -e "${RED}Не удалось прочитать файл.${NC}"
                       read -rp "$(tr_text PRESS_ENTER)" ;;
                    2) [ "$mode" != "block" ] && {
                           if [ "$mode" = "truncate" ]; then
                               $SUDO truncate -s 0 "$target" && echo -e "${GREEN}✅ Файл очищен.${NC}" \
                                   || echo -e "${RED}❌ Не удалось очистить файл.${NC}"
                           else
                               $SUDO rm -f "$target" && echo -e "${GREEN}✅ Файл удалён.${NC}" \
                                   || echo -e "${RED}❌ Не удалось удалить файл.${NC}"
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
        echo -e "  ${DIM}Свободно: ${GREEN}$(_clean_human "$(_clean_get_free)")${NC}"
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
