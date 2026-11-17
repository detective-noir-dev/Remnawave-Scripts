#!/bin/bash
# lib/menus.sh — Дашборд, подменю верхнего уровня и главное меню
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

# кэш дашборда и флаг «обновления уже проверялись в этой сессии»
_DASH_CACHE_INIT=0
_DASH_EXT_IP=""
_DASH_PING=""
_DASH_VIRT=""
_UPDATE_CHECKED=0

submenu_server() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_SERVER)"

        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_SSH_PORT)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_ZAPRET)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text SUB_HY2_SUBMENU)"
        echo -e "  ${YELLOW}4)${NC} $(tr_text SUB_WARP)"
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        read -rp "> " choice

        case $choice in
            1) show_banner; change_ssh_port ;;
            2) show_banner; install_zapret ;;
            3) submenu_hysteria2 ;;
            4) submenu_warp ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

# ====== ПОДМЕНЮ 4: Maintenance ======
submenu_maintenance() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_SETTINGS)"

        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_UPDATE)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_ROLLBACK)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text SUB_VERIFY)"
        echo -e "  ${YELLOW}4)${NC} $(tr_text SUB_APT_UPDATE)"
        echo -e "  ${YELLOW}5)${NC} $(tr_text GROUP_CLEANER)"
        echo -e "  ${YELLOW}6)${NC} $(tr_text GROUP_MEMORY)"
        echo -e "  ${YELLOW}7)${NC} $(tr_text GROUP_SCANNER)"
        echo -e "  ${RED}8)${NC} $(tr_text SUB_DELETE)"
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        read -rp "> " choice

        case $choice in
            1) show_banner; check_update ;;
            2) show_banner; rollback_update && exec "$SCRIPT_PATH"
               read -rp "$(tr_text PRESS_ENTER)" ;;
            3) show_banner; verify_install; read -rp "$(tr_text PRESS_ENTER)" ;;
            4) show_banner; apt_update_upgrade ;;
            5) submenu_cleaner ;;
            6) submenu_memory ;;
            7) submenu_scanner ;;
            8) show_banner; delete_self ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

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
                kvm|qemu)  _DASH_VIRT="KVM" ;;
                lxc)       _DASH_VIRT="LXC" ;;
                openvz)    _DASH_VIRT="OpenVZ" ;;
                none)      _DASH_VIRT="bare metal" ;;
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
        [[ "$pct" =~ ^[0-9]+$ ]] || pct=0
        [ "$pct" -gt 100 ] && pct=100
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

    # ── Отрисовка ──
    # компактный дашборд: заголовок + 2 строки о системе + 3 строки с барами
    local cpu_bar_s ram_bar_s disk_bar_s
    cpu_bar_s=$(_pbar "$cpu_pct" 12)
    ram_bar_s=$(_pbar "$ram_pct" 12)
    disk_bar_s=$(_pbar "$disk_pct" 12)

    echo -e "  ${BOLD}${CYAN}🚀 REMNAWAVE-SCRIPTS${NC} ${GREEN}v${VERSION}${NC} ${DIM}· ${lang_display}${NC}"
    echo -e "  ${DIM}──────────────────────────────────────────${NC}"
    echo -e "  ${os_name} ${DIM}(${kernel}) · ${_DASH_VIRT} · up ${uptime_str}${NC}"
    echo -e "  ${YELLOW}${_DASH_EXT_IP}${NC} ${DIM}· ping ${_DASH_PING}${NC}"
    local _svc; _svc=$(svc_summary)
    [ -n "$_svc" ] && echo -e "  ${DIM}svc${NC} ${_svc}"
    echo -e "  ${CYAN}CPU ${NC}${cpu_bar_s} ${BOLD}$(printf '%3s' "$cpu_pct")%${NC} ${DIM}${cpu_cores} vCPU${NC}"
    echo -e "  ${CYAN}RAM ${NC}${ram_bar_s} ${BOLD}$(printf '%3s' "$ram_pct")%${NC} ${DIM}${ram_used_g}G / ${ram_total_g}G${NC}"
    echo -e "  ${CYAN}${disk_type:0:3} ${NC}${disk_bar_s} ${BOLD}$(printf '%3s' "$disk_pct")%${NC} ${DIM}${disk_used} / ${disk_total}${NC}"
}

show_main_menu() {
    while true; do
        show_dashboard

        # Проверка обновлений — только при первом открытии меню
        if [ "$_UPDATE_CHECKED" -eq 0 ]; then
            auto_check_update
            _UPDATE_CHECKED=1
        fi

        echo -e "  ${DIM}──────────────────────────────────────────${NC}"
        echo -e "  ${YELLOW}1)${NC} $(tr_text GROUP_ID_FLAGS)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text GROUP_MONITOR)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text GROUP_PORTS)"
        echo -e "  ${YELLOW}4)${NC} $(tr_text GROUP_SETTINGS)"
        echo -e "  ${YELLOW}5)${NC} $(tr_text GROUP_SERVER)"
        echo -e "  ${YELLOW}6)${NC} $(tr_text GROUP_THIRDPARTY)"
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_EXIT)"

        read -rp "  > " choice

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
