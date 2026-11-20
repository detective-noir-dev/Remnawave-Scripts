#!/bin/bash
# lib/hy2.sh — Hysteria2: установка, конфиг, сервис, интеграция с Remnanode
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

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
        echo -e "$(tr_text L_HY2_001 "${ver}")"
        echo -e "$(tr_text L_HY2_002)"
        echo
        echo -e "$(tr_text L_HY2_003)"
        read -r ans
        [[ ! "$ans" =~ ^[YyДд]$ ]] && { read -rp "$(tr_text PRESS_ENTER)"; return 0; }
        echo
    fi

    echo -e "${BLUE}$(tr_text HY2_INSTALLING)${NC}"
    echo -e "$(tr_text L_HY2_004)"
    echo

    run_remote_script https://get.hy2.sh/
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        local new_ver
        new_ver=$(hysteria version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        echo -e "${GREEN}✅ $(tr_text HY2_INSTALLED)${NC}"
        [ -n "$new_ver" ] && echo -e "$(tr_text L_HY2_005 "${new_ver}")"
        echo
        echo -e "$(tr_text L_HY2_006)"
    else
        echo -e "$(tr_text L_HY2_007)"
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

    run_remote_script https://get.hy2.sh/ --remove
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ $(tr_text HY2_REMOVED)${NC}"
    else
        echo -e "$(tr_text L_HY2_008)"
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
        echo -e "$(tr_text L_HY2_009)"
        echo

        echo -e "${BLUE}$(tr_text HY2_DOMAIN_PROMPT)${NC}"
        read -r hy2_domain
        [ -z "$hy2_domain" ] && hy2_domain="example.com"

        echo -e "${BLUE}$(tr_text HY2_PORT_PROMPT)${NC}"
        read -r hy2_port
        if ! [[ "$hy2_port" =~ ^[0-9]+$ ]] || [ "$hy2_port" -lt 1 ] || [ "$hy2_port" -gt 65535 ]; then
            hy2_port="443"
        fi

        $SUDO mkdir -p /etc/hysteria

        $SUDO tee "$config_file" > /dev/null <<HYEOF
listen: :${hy2_port}

tls:
  cert: /etc/hysteria/server.crt
  key: /etc/hysteria/server.key

# For automatic TLS (ACME) uncomment:
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

        echo -e "$(tr_text L_HY2_010 "${config_file}")"
        echo -e "$(tr_text L_HY2_011 "${hy2_domain}")"
        echo -e "$(tr_text L_HY2_012 "${hy2_port}")"
        echo
        sleep 1
    fi

    echo -e "$(tr_text L_HY2_013)"
    sleep 1

    if command -v nano >/dev/null 2>&1; then
        $SUDO nano "$config_file"
    elif command -v vim >/dev/null 2>&1; then
        $SUDO vim "$config_file"
    elif command -v vi >/dev/null 2>&1; then
        $SUDO vi "$config_file"
    else
        echo -e "$(tr_text L_HY2_014)"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    echo
    echo -e "${GREEN}✅ $(tr_text HY2_CONFIG_SAVED)${NC}"
    echo -e "$(tr_text L_HY2_015 "${config_file}")"
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
                echo -e "$(tr_text L_HY2_016)"
                echo
                $SUDO systemctl enable --now hysteria-server.service
                echo
                echo -e "$(tr_text L_HY2_017)"
                echo
                read -rp "$(tr_text PRESS_ENTER)"
                ;;
            2)
                show_banner
                echo -e "$(tr_text L_HY2_018)"
                echo
                $SUDO systemctl restart hysteria-server.service
                echo
                echo -e "$(tr_text L_HY2_019)"
                echo
                read -rp "$(tr_text PRESS_ENTER)"
                ;;
            3)
                show_banner
                echo -e "$(tr_text L_HY2_020)"
                echo
                $SUDO systemctl status hysteria-server.service --no-pager -l
                echo
                read -rp "$(tr_text PRESS_ENTER)"
                ;;
            4)
                show_banner
                echo -e "$(tr_text L_HY2_021)"
                echo
                $SUDO systemctl stop hysteria-server.service
                echo
                echo -e "$(tr_text L_HY2_022)"
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
    echo -e "$(tr_text L_HY2_023)"
    echo
    sleep 1
    $SUDO journalctl --no-pager -e -u hysteria-server.service
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

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
    echo -e "$(tr_text L_HY2_024)"
    local latest_ver
    latest_ver=$(curl -fsSL "https://api.github.com/repos/apernet/hysteria/releases/latest" 2>/dev/null \
        | grep '"tag_name"' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)

    if [ -z "$latest_ver" ]; then
        echo -e "$(tr_text L_HY2_025)"
    else
        echo -e "${BLUE}$(tr_text HY2_VERSION_LATEST)${NC} ${CYAN}${latest_ver}${NC}"
        echo
        if [ "$installed_ver" = "$latest_ver" ]; then
            echo -e "${GREEN}✅ $(tr_text HY2_UP_TO_DATE)${NC}"
        else
            echo -e "${YELLOW}⚠️  $(tr_text HY2_UPDATE_AVAIL)${NC}"
            echo -e "$(tr_text L_HY2_026)"
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
        echo -e "$(tr_text L_HY2_027)"
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
        echo -e "$(tr_text L_HY2_028)"
        read -r ans
        [[ ! "$ans" =~ ^[YyДд]$ ]] && { read -rp "$(tr_text PRESS_ENTER)"; return 0; }
    fi

    echo
    echo -e "${BLUE}$(tr_text HY2_UPDATING)${NC}"
    echo -e "$(tr_text L_HY2_004)"
    echo

    # Официальный установщик — устанавливает или обновляет до последней версии
    run_remote_script https://get.hy2.sh/
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        local new_ver
        new_ver=$(hysteria version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        echo -e "${GREEN}✅ $(tr_text HY2_UPDATED)${NC}"
        [ -n "$new_ver" ] && echo -e "$(tr_text L_HY2_029 "${new_ver}")"
        echo
        echo -e "$(tr_text L_HY2_030)"
    else
        echo -e "${RED}❌ $(tr_text HY2_UPDATE_FAIL)${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== НАСТРОЙКА HYSTERIA2 ДЛЯ REMNANODE (Xray inbound) ======
_hy2r_open_udp() {
    local port=$1 fw
    fw=$(detect_firewall)
    case $fw in
        ufw)       ufw allow "$port"/udp >/dev/null 2>&1 ;;
        firewalld) firewall-cmd --permanent --add-port="$port"/udp >/dev/null 2>&1 && firewall-cmd --reload >/dev/null 2>&1 ;;
        iptables)  iptables -C INPUT -p udp --dport "$port" -j ACCEPT 2>/dev/null || iptables -A INPUT -p udp --dport "$port" -j ACCEPT
                   command -v netfilter-persistent >/dev/null 2>&1 && netfilter-persistent save >/dev/null 2>&1 ;;
        *)         return 1 ;;
    esac
    add_port_to_json "$port" "udp" "Hysteria2 (Remnanode)" >/dev/null 2>&1
    return 0
}

setup_hysteria2_remnanode() {
    local dir="/opt/remnanode" compose="/opt/remnanode/docker-compose.yml"
    local hook="/etc/letsencrypt/renewal-hooks/deploy/restart-remnanode.sh"
    local ssl_dir="/var/lib/remnawave/configs/xray/ssl"

    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    $(tr_text SUB_HY2_REMNA)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo

    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ $(tr_text WARP_ROOT_REQUIRED)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    if [ ! -f "$compose" ]; then
        echo -e "${RED}❌ $(tr_text HY2R_NO_COMPOSE)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    # --- уже настроено? ---
    if grep -q "$ssl_dir/cert.pem" "$compose" && grep -q "$ssl_dir/cert.key" "$compose" && [ -x "$hook" ]; then
        local cur
        cur=$(grep "$ssl_dir/cert.pem" "$compose" | sed -E 's|.*/live/([^/]+)/.*|\1|' | head -1)
        echo -e "${YELLOW}⚠️  $(tr_text HY2R_ALREADY)${NC}"
        [ -n "$cur" ] && echo -e "  ${BOLD}Domain:${NC} $cur"
        echo -e "  ${BOLD}Compose:${NC} $compose"
        echo -e "  ${BOLD}Hook:${NC}    $hook"
        echo
        echo -e "${YELLOW}$(tr_text HY2R_RECONFIGURE)${NC}"
        read -r ans
        [[ ! "$ans" =~ ^[YyДд]$ ]] && { read -rp "$(tr_text PRESS_ENTER)"; return 0; }
        echo
    fi

    local domain
    echo -e "${BLUE}$(tr_text HY2R_DOMAIN_PROMPT)${NC}"
    read -rp "> " domain
    if ! [[ "$domain" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]]; then
        echo -e "${RED}❌ $(tr_text HY2R_DOMAIN_INVALID)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    local live="/etc/letsencrypt/live/$domain"
    if [ ! -f "$live/fullchain.pem" ] || [ ! -f "$live/privkey.pem" ]; then
        echo -e "${RED}❌ $(tr_text HY2R_NO_CERT) $live${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    local port
    while true; do
        echo -e "${BLUE}$(tr_text HY2R_PORT_PROMPT)${NC}"
        read -rp "> " port
        port="${port:-443}"
        if [[ "$port" =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 )); then
            break
        fi
        echo -e "${RED}$(tr_text WARP_PORT_INVALID)${NC}"
    done

    # --- docker-compose.yml: добавляем недостающие монтирования ---
    local want=()
    grep -q '/dev/shm:/dev/shm' "$compose" || want+=("/dev/shm:/dev/shm:rw")
    grep -q "$ssl_dir/cert.pem" "$compose" || want+=("$live/fullchain.pem:$ssl_dir/cert.pem:ro")
    grep -q "$ssl_dir/cert.key" "$compose" || want+=("$live/privkey.pem:$ssl_dir/cert.key:ro")

    if [ ${#want[@]} -gt 0 ]; then
        if ! grep -qE '^[[:space:]]+volumes:[[:space:]]*$' "$compose"; then
            echo -e "${RED}❌ $(tr_text HY2R_NO_VOLUMES)${NC}"
            printf '  - %s\n' "${want[@]}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 1
        fi
        cp "$compose" "$compose.bak"
        local tmp
        tmp=$(mktemp)
        awk -v items="$(printf '%s\n' "${want[@]}")" '
            /^  [a-zA-Z_-]+:/ { svc = $1 }
            { print }
            svc ~ /remnanode/ && !done && /^[[:space:]]+volumes:[[:space:]]*$/ {
                match($0, /^[[:space:]]*/)
                ind = substr($0, 1, RLENGTH) "  "
                n = split(items, a, "\n")
                for (i = 1; i <= n; i++) print ind "- " a[i]
                done = 1
            }' "$compose" > "$tmp" && [ -s "$tmp" ] && cat "$tmp" > "$compose"
        local awk_rc=$?
        rm -f "$tmp"
        if [ $awk_rc -ne 0 ]; then
            echo -e "${RED}❌ $(tr_text HY2R_NO_VOLUMES)${NC}"
            printf '  - %s\n' "${want[@]}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 1
        fi
        echo -e "${GREEN}✅ $(tr_text HY2R_COMPOSE_DONE)${NC}"
    fi

    # --- хук перезапуска при продлении сертификата ---
    mkdir -p "$(dirname "$hook")"
    printf '#!/bin/bash\ncd %s && docker compose restart remnanode\n' "$dir" > "$hook"
    chmod +x "$hook"
    echo -e "${GREEN}✅ $(tr_text HY2R_HOOK_DONE)${NC}"

    # --- файрвол ---
    if _hy2r_open_udp "$port"; then
        echo -e "${GREEN}✅ UDP $port${NC}"
    else
        echo -e "$(tr_text L_HY2_031 "$port")"
    fi

    # --- перезапуск ---
    echo
    echo -e "${YELLOW}$(tr_text HY2R_RESTART_CONFIRM)${NC}"
    read -r ans
    if [[ "$ans" =~ ^[YyДд]$ ]]; then
        if ! (cd "$dir" && docker compose down && docker compose up -d); then
            echo -e "${RED}❌ $(tr_text HY2R_RESTART_FAIL)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 1
        fi
    fi

    echo
    echo -e "${GREEN}✅ $(tr_text HY2R_DONE)${NC}"
    echo -e "${BLUE}$(tr_text HY2R_XRAY_HINT)${NC}"
    echo -e "  ${BOLD}${YELLOW}certificateFile${NC}: $ssl_dir/cert.pem"
    echo -e "  ${BOLD}${YELLOW}keyFile${NC}:         $ssl_dir/cert.key"
    echo -e "  ${BOLD}${YELLOW}port${NC}:            $port/udp"
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

submenu_hysteria2() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text SUB_HY2_SUBMENU)"

        echo -e "  ${BOLD}${CYAN}$(tr_text HY2_GROUP_MIHOMO)${NC}"
        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_HY2_INSTALL)"
        echo -e "  ${RED}2)${NC} $(tr_text SUB_HY2_REMOVE)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text SUB_HY2_CONFIG)"
        echo -e "  ${YELLOW}4)${NC} $(tr_text SUB_HY2_MANAGE)"
        echo -e "  ${YELLOW}5)${NC} $(tr_text SUB_HY2_LOGS)"
        echo -e "  ${YELLOW}6)${NC} $(tr_text SUB_HY2_VERSION)"
        echo -e "  ${YELLOW}7)${NC} $(tr_text SUB_HY2_UPDATE)"
        echo
        echo -e "  ${BOLD}${CYAN}$(tr_text HY2_GROUP_NODE)${NC}"
        echo -e "  ${YELLOW}8)${NC} $(tr_text SUB_HY2_REMNA)"
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
            8) show_banner; setup_hysteria2_remnanode ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}
