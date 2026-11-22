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
        echo -e "  ${YELLOW}5)${NC} $(tr_text SUB_DANTE)"
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        read -rp "> " choice

        case $choice in
            1) show_banner; change_ssh_port ;;
            2) show_banner; install_zapret ;;
            3) submenu_hysteria2 ;;
            4) submenu_warp ;;
            5) submenu_dante ;;
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
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_APT_UPDATE)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text GROUP_CLEANER)"
        echo -e "      ${DIM}$(tr_text HINT_CLEANER)${NC}"
        echo -e "  ${YELLOW}4)${NC} $(tr_text GROUP_MEMORY)"
        echo -e "      ${DIM}$(tr_text HINT_MEMORY)${NC}"
        echo -e "  ${YELLOW}5)${NC} $(tr_text GROUP_SCANNER)"
        echo -e "      ${DIM}$(tr_text HINT_SCANNER)${NC}"
        echo -e "  ${YELLOW}6)${NC} $(tr_text SUB_ROLLBACK)"
        echo -e "  ${RED}7)${NC} $(tr_text SUB_DELETE)"
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        read -rp "> " choice

        case $choice in
            1) show_banner; check_update ;;
            2) show_banner; apt_update_upgrade ;;
            3) submenu_cleaner ;;
            4) submenu_memory ;;
            5) submenu_scanner ;;
            6) show_banner; rollback_update && exec "$SCRIPT_PATH"
               read -rp "$(tr_text PRESS_ENTER)" ;;
            7) show_banner; delete_self ;;
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

    # ── Прогресс-бар: _pbar <pct> [ширина]; заполненная часть цветная по порогам, пустая приглушена ──
    _pcol() {
        local pct=${1:-0}
        if   [ "$pct" -ge 90 ]; then echo -n "$RED"
        elif [ "$pct" -ge 70 ]; then echo -n "$YELLOW"
        else                          echo -n "$GREEN"
        fi
    }
    _pbar() {
        local pct=${1:-0} w=${2:-12} filled i b=""
        [[ "$pct" =~ ^[0-9]+$ ]] || pct=0
        [ "$pct" -gt 100 ] && pct=100
        filled=$(( pct * w / 100 ))
        b+="$(_pcol "$pct")"
        for ((i=0; i<filled; i++)); do b+="█"; done
        b+="${NC}${DIM}"
        for ((i=filled; i<w; i++)); do b+="░"; done
        b+="${NC}"
        echo -e "$b"
    }
    # строка бара: _dash_bar МЕТКА ПРОЦЕНТ ПОДПИСЬ
    _dash_bar() {
        echo -e "  ${CYAN}${BOLD}$(printf '%-5s' "$1")${NC}$(_pbar "$2") $(_pcol "$2")${BOLD}$(printf '%3s' "$2")%${NC}  ${DIM}$3${NC}"
    }

    # ── Отрисовка ──
    local rule_h rule_l os_short up_short
    rule_h="${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    rule_l="${DIM}──────────────────────────────────────────────${NC}"
    os_short="${os_name// GNU\/Linux/}"
    up_short=$(echo "$uptime_str" | sed -E 's/ years?/y/;s/ weeks?/w/;s/ days?/d/;s/ hours?/h/;s/ minutes?/m/;s/,//g')

    echo -e "  $rule_h"
    echo -e "  ${BOLD}${CYAN}🚀 REMNAWAVE-SCRIPTS${NC}  ${GREEN}v${VERSION}${NC} ${DIM}· ${lang_display}${NC}"
    echo -e "  $rule_h"
    echo -e "  ${DIM}SYS${NC}  ${os_short} ${DIM}· ${_DASH_VIRT} · kernel ${kernel}${NC}"
    echo -e "  ${DIM}NET${NC}  ${YELLOW}${_DASH_EXT_IP}${NC} ${DIM}· ping ${_DASH_PING} · up ${up_short}${NC}"
    local _svc; _svc=$(svc_summary)
    [ -n "$_svc" ] && echo -e "  ${DIM}SVC${NC}  ${_svc}"
    echo -e "  $rule_l"
    _dash_bar "CPU" "$cpu_pct" "${cpu_cores} vCPU"
    _dash_bar "RAM" "$ram_pct" "${ram_used_g}G / ${ram_total_g}G"
    _dash_bar "${disk_type:0:4}" "$disk_pct" "${disk_used} / ${disk_total}"
    echo -e "  $rule_h"
}

show_main_menu() {
    while true; do
        show_dashboard

        # Проверка обновлений — только при первом открытии меню
        if [ "$_UPDATE_CHECKED" -eq 0 ]; then
            auto_check_update
            _UPDATE_CHECKED=1
        fi

        _mi() {
            echo -e "  ${DIM}[${NC}${BOLD}${YELLOW}$1${NC}${DIM}]${NC} $2"
            [ -n "${3:-}" ] && echo -e "      ${DIM}$3${NC}"
        }
        _mi 1 "$(tr_text GROUP_ID_FLAGS)"   "$(tr_text HINT_ID_FLAGS)"
        _mi 2 "$(tr_text GROUP_MONITOR)"    "$(tr_text HINT_MONITOR)"
        _mi 3 "$(tr_text GROUP_PORTS)"      "$(tr_text HINT_PORTS)"
        _mi 4 "$(tr_text GROUP_SETTINGS)"   "$(tr_text HINT_SETTINGS)"
        _mi 5 "$(tr_text GROUP_SERVER)"     "$(tr_text HINT_SERVER)"
        _mi 6 "$(tr_text GROUP_THIRDPARTY)" "$(tr_text HINT_THIRDPARTY)"
        echo -e "  ${DIM}[0] $(tr_text MENU_EXIT)${NC}"
        echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

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
