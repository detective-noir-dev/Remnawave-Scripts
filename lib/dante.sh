#!/bin/bash
# lib/dante.sh — SOCKS5-прокси Dante: установка, whitelist по IP, статус, перезапуск, удаление.
# Подключается из scripts.sh через load_modules; сам по себе не запускается.
# Совместим с `set -u`: необязательные переменные через ${имя:-}.

DANTE_CONF="/etc/danted.conf"

# ====== ПОМОЩНИКИ ======

_dante_installed() { command -v danted >/dev/null 2>&1; }

_dante_valid_ip() {
    local ip=$1 o
    [[ "$ip" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]] || return 1
    for o in "${BASH_REMATCH[@]:1}"; do (( 10#$o <= 255 )) || return 1; done
    [ "$ip" != "0.0.0.0" ]
}

_dante_valid_port() { [[ "${1:-}" =~ ^[0-9]+$ ]] && (( $1 >= 1 && $1 <= 65535 )); }

# интерфейс с маршрутом по умолчанию
_dante_iface() {
    ip -4 route get 1.1.1.1 2>/dev/null \
        | awk '{for(i=1;i<NF;i++) if($i=="dev"){print $(i+1); exit}}'
}

_dante_port() {
    [ -r "$DANTE_CONF" ] || return 0
    sed -n 's/^internal:.*port *= *\([0-9]*\).*/\1/p' "$DANTE_CONF" | head -1
}

_dante_conf_iface() {
    [ -r "$DANTE_CONF" ] || return 0
    sed -n 's/^internal: *\([^ ]*\) .*/\1/p' "$DANTE_CONF" | head -1
}

# IP из блоков client pass (по одному в строке)
_dante_ips() {
    [ -r "$DANTE_CONF" ] || return 0
    awk '/^client pass/{f=1;next} f&&/from:/{split($2,a,"/");print a[1]} /^}/{f=0}' "$DANTE_CONF"
}

# Спрашивает разрешённые IP (через пробел или запятую), результат — массив DANTE_IPS
_dante_ask_ips() {
    local line ip
    DANTE_IPS=()
    while true; do
        echo -e "${BLUE}$(tr_text L_DANTE_IP_PROMPT)${NC}"
        read -rp "> " line
        line=${line//,/ }
        DANTE_IPS=()
        local ok=1
        for ip in $line; do
            if _dante_valid_ip "$ip"; then
                DANTE_IPS+=("$ip")
            else
                echo -e "${RED}$(tr_text L_DANTE_IP_BAD) $ip${NC}"
                ok=0; break
            fi
        done
        [ "$ok" -eq 1 ] && [ "${#DANTE_IPS[@]}" -gt 0 ] && return 0
        [ -z "${line// /}" ] && return 1
    done
}

# ====== ФАЕРВОЛ: правило «только этому IP на этот порт» ======
# _dante_fw add|del IP PORT
_dante_fw() {
    local act=$1 ip=$2 port=$3 rule
    case "$(detect_firewall)" in
        ufw)
            if [ "$act" = add ]; then
                $SUDO ufw allow from "$ip" to any port "$port" proto tcp >/dev/null 2>&1
            else
                $SUDO ufw delete allow from "$ip" to any port "$port" proto tcp >/dev/null 2>&1
            fi
            return $?
            ;;
        firewalld)
            rule="rule family=ipv4 source address=$ip port port=$port protocol=tcp accept"
            if [ "$act" = add ]; then
                $SUDO firewall-cmd --permanent --add-rich-rule="$rule" >/dev/null 2>&1
            else
                $SUDO firewall-cmd --permanent --remove-rich-rule="$rule" >/dev/null 2>&1
            fi
            [ $? -eq 0 ] && $SUDO firewall-cmd --reload >/dev/null 2>&1
            return $?
            ;;
        iptables)
            if [ "$act" = add ]; then
                $SUDO iptables -A INPUT -p tcp -s "$ip" --dport "$port" -j ACCEPT 2>/dev/null
            else
                $SUDO iptables -D INPUT -p tcp -s "$ip" --dport "$port" -j ACCEPT 2>/dev/null
            fi
            return $?
            ;;
        *) return 0 ;;
    esac
}

# ====== КОНФИГ ======
# _dante_write_conf ПОРТ ИНТЕРФЕЙС IP...
_dante_write_conf() {
    local port=$1 iface=$2 ip tmp out
    shift 2
    tmp=$(mktemp) || return 1
    {
        echo "logoutput: syslog"
        echo "user.privileged: root"
        echo "user.unprivileged: nobody"
        echo "internal: $iface port = $port"
        echo "external: $iface"
        echo "clientmethod: none"
        echo "socksmethod: none"
        for ip in "$@"; do
            printf 'client pass {\n    from: %s/32 to: 0.0.0.0/0\n    log: error\n}\n' "$ip"
        done
        printf 'client block {\n    from: 0.0.0.0/0 to: 0.0.0.0/0\n    log: error\n}\n'
        for ip in "$@"; do
            printf 'socks pass {\n    from: %s/32 to: 0.0.0.0/0\n    log: error\n}\n' "$ip"
        done
        printf 'socks block {\n    from: 0.0.0.0/0 to: 0.0.0.0/0\n    log: error\n}\n'
    } > "$tmp"

    # проверяем синтаксис до замены рабочего конфига
    if ! out=$($SUDO danted -Vf "$tmp" 2>&1); then
        echo -e "${RED}$(tr_text L_DANTE_CONF_BAD)${NC}"
        printf '%s\n' "$out" | tail -n 5 | sed 's/^/   /'
        rm -f "$tmp"
        return 1
    fi
    [ -f "$DANTE_CONF" ] && $SUDO cp -a "$DANTE_CONF" "$DANTE_CONF.bak"
    $SUDO install -m 644 "$tmp" "$DANTE_CONF"
    local rc=$?
    rm -f "$tmp"
    return "$rc"
}

# ====== УСТАНОВКА / НАСТРОЙКА ======
_dante_install() {
    show_banner
    print_submenu_header "$(tr_text SUB_DANTE_SUBMENU)"
    echo

    if ! _dante_installed; then
        run_step "$(tr_text L_DANTE_INSTALLING)" \
            pkg_install_any dante-server dante || {
            read -rp "$(tr_text PRESS_ENTER)"; return 1; }
    fi

    local iface port
    iface=$(_dante_iface)
    echo -e "${CYAN}$(tr_text L_DANTE_IFACE_PROMPT) [${iface:-ens3}]:${NC}"
    read -rp "> " ans
    iface=${ans:-${iface:-ens3}}
    ip link show "$iface" >/dev/null 2>&1 || {
        echo -e "${RED}$(tr_text L_DANTE_IFACE_BAD) $iface${NC}"
        read -rp "$(tr_text PRESS_ENTER)"; return 1; }

    while true; do
        echo -e "${CYAN}$(tr_text L_DANTE_PORT_PROMPT) [1080]:${NC}"
        read -rp "> " port
        port=${port:-1080}
        _dante_valid_port "$port" && break
        echo -e "${RED}$(tr_text L_DANTE_PORT_BAD)${NC}"
    done
    if ss -tln "sport = :$port" 2>/dev/null | grep -q LISTEN && [ "$port" != "$(_dante_port)" ]; then
        echo -e "${RED}$(tr_text L_DANTE_PORT_BUSY)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"; return 1
    fi

    _dante_ask_ips || {
        echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"; return 0; }

    # снимаем старые правила фаервола при повторной настройке
    local old_port old_ip
    old_port=$(_dante_port)
    if [ -n "$old_port" ]; then
        for old_ip in $(_dante_ips); do
            _dante_fw del "$old_ip" "$old_port" || {
                echo -e "${RED}❌ $(tr_text L_DANTE_FW_FAIL)${NC}"
                read -rp "$(tr_text PRESS_ENTER)"; return 1; }
        done
    fi

    _dante_write_conf "$port" "$iface" "${DANTE_IPS[@]}" || {
        read -rp "$(tr_text PRESS_ENTER)"; return 1; }

    local ip
    for ip in "${DANTE_IPS[@]}"; do
        _dante_fw add "$ip" "$port" || {
            echo -e "${RED}❌ $(tr_text L_DANTE_FW_FAIL)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"; return 1; }
    done
    run_step "$(tr_text L_DANTE_FW_LABEL)" true

    run_step "$(tr_text L_DANTE_ENABLE)" $SUDO systemctl enable danted
    run_step "$(tr_text L_DANTE_RESTART)" $SUDO systemctl restart danted

    echo
    _dante_print_summary
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== СМЕНА РАЗРЕШЁННЫХ IP ======
_dante_change_ips() {
    show_banner
    print_submenu_header "$(tr_text L_DANTE_IP_CHANGE_HDR)"
    _dante_installed && [ -f "$DANTE_CONF" ] || {
        echo -e "${YELLOW}$(tr_text L_DANTE_NOT_CONFIGURED)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"; return 1; }

    local port iface old
    port=$(_dante_port); iface=$(_dante_conf_iface)
    echo -e "$(tr_text L_DANTE_IP_CURRENT): ${CYAN}$(_dante_ips | tr '\n' ' ')${NC}"
    echo
    _dante_ask_ips || {
        echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"; return 0; }

    for old in $(_dante_ips); do
        _dante_fw del "$old" "$port" || {
            echo -e "${RED}❌ $(tr_text L_DANTE_FW_FAIL)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"; return 1; }
    done
    _dante_write_conf "$port" "$iface" "${DANTE_IPS[@]}" || {
        read -rp "$(tr_text PRESS_ENTER)"; return 1; }
    for old in "${DANTE_IPS[@]}"; do
        _dante_fw add "$old" "$port" || {
            echo -e "${RED}❌ $(tr_text L_DANTE_FW_FAIL)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"; return 1; }
    done
    run_step "$(tr_text L_DANTE_RESTART)" $SUDO systemctl restart danted
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== СТАТУС ======
# danted привязывается к адресу интерфейса при старте.
# После смены IP у сервера нужен restart — статус об этом предупреждает.
_dante_bind_state() {
    local port iface listen cur l stale=0
    port=$(_dante_port); iface=$(_dante_conf_iface)
    [ -n "$port" ] && [ -n "$iface" ] || return 0
    listen=$(ss -tln "sport = :$port" 2>/dev/null \
        | awk '{print $4}' | grep -E '^[0-9.]+:' | cut -d: -f1)
    cur=$(ip -4 -o addr show dev "$iface" 2>/dev/null \
        | awk '{split($4,a,"/");print a[1]}')
    if [ -z "$listen" ]; then
        echo -e "  ${RED}✖${NC} $(tr_text L_DANTE_NO_LISTEN) $port"
        return 0
    fi
    for l in $listen; do
        [ "$l" = "0.0.0.0" ] && continue
        grep -qx "$l" <<<"$cur" || {
            stale=1
            echo -e "  ${YELLOW}⚠${NC} $(tr_text L_DANTE_STALE_ADDR): $l"
        }
    done
    if [ "$stale" -eq 1 ]; then
        echo -e "  ${YELLOW}→ $(tr_text L_DANTE_STALE_HINT)${NC}"
    else
        echo -e "  ${GREEN}✔${NC} $(tr_text L_DANTE_LISTEN_OK): $listen"
    fi
}

_dante_print_summary() {
    local port ips pub
    port=$(_dante_port); ips=$(_dante_ips | tr '\n' ' ')
    pub=${_DASH_EXT_IP:-$(curl -4 -s --connect-timeout 3 ifconfig.me 2>/dev/null)}
    echo -e "  ${BOLD}$(tr_text L_DANTE_PORT_LBL):${NC} ${port:-?}"
    echo -e "  ${BOLD}$(tr_text L_DANTE_ALLOWED_LBL):${NC} ${ips:-—}"
    _dante_bind_state
    echo
    echo -e "  ${DIM}$(tr_text L_DANTE_TEST_HINT):${NC}"
    echo -e "  ${YELLOW}curl -x socks5h://${pub:-<IP>}:${port:-1080} https://api.telegram.org${NC}"
    echo -e "  ${DIM}$(tr_text L_DANTE_BOT_HINT): TG_PROXY=\"socks5h://${pub:-<IP>}:${port:-1080}\"${NC}"
}

_dante_status() {
    show_banner
    print_submenu_header "$(tr_text L_DANTE_STATUS_HDR)"
    if ! _dante_installed; then
        echo -e "${YELLOW}$(tr_text L_DANTE_NOT_INSTALLED)${NC}"
    else
        if systemctl is-active --quiet danted; then
            echo -e "  ${GREEN}✔${NC} danted active"
        else
            echo -e "  ${RED}✖${NC} danted inactive"
        fi
        _dante_print_summary
        # предупреждение если прокси открыт для всего мира
        if grep -q '^client pass' "$DANTE_CONF" 2>/dev/null \
           && awk '/^client pass/{f=1} f&&/from: *0\.0\.0\.0\/0/{found=1} /^}/{f=0} END{exit !found}' "$DANTE_CONF"; then
            echo
            echo -e "  ${RED}⚠ $(tr_text L_DANTE_OPEN_WORLD)${NC}"
        fi
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== УДАЛЕНИЕ ======
_dante_remove() {
    show_banner
    _dante_installed || {
        echo -e "${YELLOW}$(tr_text L_DANTE_NOT_INSTALLED)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"; return 0; }
    read -rp "$(tr_text L_DANTE_REMOVE_CONFIRM)" ans
    [[ "$ans" =~ ^[YyДд]$ ]] || {
        echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"; return 0; }

    local port ip
    port=$(_dante_port)
    if [ -n "$port" ]; then
        for ip in $(_dante_ips); do
            _dante_fw del "$ip" "$port" || {
                echo -e "${RED}❌ $(tr_text L_DANTE_FW_FAIL)${NC}"
                read -rp "$(tr_text PRESS_ENTER)"; return 1; }
        done
    fi
    $SUDO systemctl disable --now danted >/dev/null 2>&1
    run_step "$(tr_text L_DANTE_REMOVING)" \
        pkg_remove_any dante-server dante
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== ПОДМЕНЮ ======
submenu_dante() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text SUB_DANTE_SUBMENU)"
        echo -e "  ${YELLOW}1)${NC} $(tr_text L_DANTE_M1)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text L_DANTE_M2)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text L_DANTE_M3)"
        echo -e "  ${YELLOW}4)${NC} $(tr_text L_DANTE_M4)"
        echo -e "  ${YELLOW}5)${NC} $(tr_text L_DANTE_M5)"
        echo -e "  ${RED}6)${NC} $(tr_text L_DANTE_M6)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        case $choice in
            1) _dante_install ;;
            2) _dante_change_ips ;;
            3) _dante_status ;;
            4) show_banner
               run_step "$(tr_text L_DANTE_RESTART)" $SUDO systemctl restart danted
               echo; _dante_bind_state; echo
               read -rp "$(tr_text PRESS_ENTER)" ;;
            5) show_banner
               $SUDO journalctl --no-pager -n 50 -u danted
               echo; read -rp "$(tr_text PRESS_ENTER)" ;;
            6) _dante_remove ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}
