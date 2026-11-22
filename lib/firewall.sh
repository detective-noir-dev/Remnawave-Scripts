#!/bin/bash
# lib/firewall.sh — Файрвол и управление портами (ufw, firewalld, iptables, ports.json)
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

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
    
    echo -e "$(tr_text L_FIREWALL_001)"
    loading_bar & pid=$!
    
    if ! pkg_mgr >/dev/null; then
        kill $pid >/dev/null 2>&1; tput cnorm
        echo -e "$(tr_text L_FIREWALL_002)"
        return 1
    fi
    pkg_install jq &>/dev/null
    
    kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm
    
    if command -v jq >/dev/null 2>&1; then
        echo -e "$(tr_text L_FIREWALL_003)"
        return 0
    else
        echo -e "$(tr_text L_FIREWALL_004)"
        return 1
    fi
}

add_port_to_json() {
    local port=$1 protocol=$2 description=$3
    local timestamp=$(date +%s)
    
    init_ports_file
    ensure_jq || return 1
    
    local temp_file=$(mktemp)
    jq --arg p "$port" --arg pr "$protocol" --arg d "$description" --argjson t "$timestamp" \
        '. += [{port: $p, protocol: $pr, description: $d, timestamp: $t}]' "$PORTS_FILE" > "$temp_file" \
        && mv "$temp_file" "$PORTS_FILE" || { rm -f "$temp_file"; return 1; }
}

remove_port_from_json() {
    local port=$1 protocol=$2
    ensure_jq || return 1
    
    local temp_file=$(mktemp)
    jq --arg p "$port" --arg pr "$protocol" 'map(select(.port != $p or .protocol != $pr))' "$PORTS_FILE" > "$temp_file" \
        && mv "$temp_file" "$PORTS_FILE" || { rm -f "$temp_file"; return 1; }
}

edit_port_description() {
    local port=$1 protocol=$2 new_description=$3
    ensure_jq || return 1
    
    local temp_file=$(mktemp)
    jq --arg p "$port" --arg pr "$protocol" --arg d "$new_description" \
        'map(if .port == $p and .protocol == $pr then .description = $d else . end)' "$PORTS_FILE" > "$temp_file" \
        && mv "$temp_file" "$PORTS_FILE" || { rm -f "$temp_file"; return 1; }
}

# ====== ПОЛУЧЕНИЕ РЕАЛЬНЫХ ОТКРЫТЫХ ПОРТОВ ИЗ FIREWALL ======
get_firewall_ports() {
    local firewall=$(detect_firewall)
    local ports_list=""
    
    case $firewall in
        ufw)
            # Парсим вывод ufw status
            ports_list=$($SUDO ufw status 2>/dev/null | grep -E "^[0-9]+/(tcp|udp)" | while read line; do
                port=$(echo "$line" | grep -oE "^[0-9]+" | head -1)
                proto=$(echo "$line" | grep -oE "(tcp|udp)" | head -1)
                echo "$port|$proto"
            done)
            
            # Также парсим порты в формате "443/tcp ALLOW"
            ports_list+=$'\n'$($SUDO ufw status 2>/dev/null | grep -E "ALLOW" | grep -oE "[0-9]+/(tcp|udp)" | while read line; do
                port=$(echo "$line" | cut -d'/' -f1)
                proto=$(echo "$line" | cut -d'/' -f2)
                echo "$port|$proto"
            done)
            ;;
        firewalld)
            # Получаем порты из firewalld
            ports_list=$($SUDO firewall-cmd --list-ports 2>/dev/null | tr ' ' '\n' | while read line; do
                if [ -n "$line" ]; then
                    port=$(echo "$line" | cut -d'/' -f1)
                    proto=$(echo "$line" | cut -d'/' -f2)
                    echo "$port|$proto"
                fi
            done)
            ;;
        iptables)
            # Парсим iptables для открытых портов
            ports_list=$($SUDO iptables -L INPUT -n 2>/dev/null | grep -E "ACCEPT.*dpt:" | while read line; do
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
        echo -e "$(tr_text L_FIREWALL_005)"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "$(tr_text L_FIREWALL_006)"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo
    read -rp "$(tr_text L_FIREWALL_007)" port
    
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "$(tr_text L_FIREWALL_008)"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    echo
    echo "$(tr_text L_FIREWALL_009)"
    echo -e "${YELLOW}1)${NC} TCP"
    echo -e "${YELLOW}2)${NC} UDP"
    echo -e "$(tr_text L_FIREWALL_010)"
    read -rp "> " proto_choice
    
    case $proto_choice in
        1) protocol="tcp" ;;
        2) protocol="udp" ;;
        3) protocol="both" ;;
        *) echo -e "$(tr_text L_FIREWALL_011)"; return 1 ;;
    esac
    
    read -rp "$(tr_text L_FIREWALL_012)" description
    [ -z "$description" ] && description="No description"
    
    echo -e "$(tr_text L_FIREWALL_013 "$port" "$protocol")"

    if port_apply open "$port" "$protocol" "$description"; then
        echo -e "$(tr_text L_FIREWALL_014 "$port" "$protocol")"
    else
        echo -e "$(tr_text L_FIREWALL_036 "$port")"
    fi
    read -rp "$(tr_text PRESS_ENTER)"
}

close_port() {
    local firewall=$(detect_firewall)
    
    if [ "$firewall" = "none" ]; then
        echo -e "$(tr_text L_FIREWALL_005)"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    # Синхронизируем перед показом
    sync_ports_with_firewall
    list_ports
    
    if [ ! -s "$PORTS_FILE" ] || [ "$(cat "$PORTS_FILE")" = "[]" ]; then
        echo -e "$(tr_text L_FIREWALL_015)"
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi
    
    echo
    read -rp "$(tr_text L_FIREWALL_016)" port
    
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "$(tr_text L_FIREWALL_008)"
        return 1
    fi
    
    echo "$(tr_text L_FIREWALL_017)"
    read -rp "> " proto_choice
    
    case $proto_choice in
        1) protocol="tcp" ;;
        2) protocol="udp" ;;
        3) protocol="both" ;;
        *) return 1 ;;
    esac
    
    if port_apply close "$port" "$protocol"; then
        echo -e "$(tr_text L_FIREWALL_018 "$port")"
    else
        echo -e "$(tr_text L_FIREWALL_037 "$port")"
    fi
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
    read -rp "$(tr_text L_FIREWALL_019)" port
    echo "$(tr_text L_FIREWALL_020)"
    read -rp "> " proto_choice
    
    case $proto_choice in
        1) protocol="tcp" ;;
        2) protocol="udp" ;;
        *) return 1 ;;
    esac
    
    ensure_jq || return 1
    local exists=$(jq -r --arg p "$port" --arg pr "$protocol" '.[] | select(.port == $p and .protocol == $pr) | .description' "$PORTS_FILE")
    
    if [ -z "$exists" ]; then
        echo -e "$(tr_text L_FIREWALL_021)"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    
    echo -e "$(tr_text L_FIREWALL_022 "$exists")"
    read -rp "$(tr_text L_FIREWALL_023)" new_description
    
    [ -n "$new_description" ] && edit_port_description "$port" "$protocol" "$new_description"
    echo -e "$(tr_text L_FIREWALL_024)"
    read -rp "$(tr_text PRESS_ENTER)"
}

list_ports() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "$(tr_text L_FIREWALL_025)"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    
    init_ports_file
    
    # Синхронизируем порты с firewall
    echo -e "$(tr_text L_FIREWALL_026)"
    sync_ports_with_firewall
    
    if [ ! -s "$PORTS_FILE" ] || [ "$(cat "$PORTS_FILE")" = "[]" ]; then
        echo -e "$(tr_text L_FIREWALL_027)"
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
    
    echo -e "$(tr_text L_FIREWALL_028 "$total" "$script_count" "$system_count")"
}

show_firewall_status() {
    local firewall=$(detect_firewall)
    
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "$(tr_text L_FIREWALL_029)"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo
    
    case $firewall in
        ufw)
            echo -e "${GREEN}Firewall: UFW${NC}"
            $SUDO ufw status verbose
            ;;
        firewalld)
            echo -e "${GREEN}Firewall: FirewallD${NC}"
            $SUDO firewall-cmd --state
            $SUDO firewall-cmd --list-all
            ;;
        iptables)
            echo -e "${GREEN}Firewall: iptables${NC}"
            $SUDO iptables -L -n -v --line-numbers
            ;;
        none)
            echo -e "$(tr_text L_FIREWALL_030)"
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
        
        echo -e "$(tr_text L_FIREWALL_031)"
        echo -e "$(tr_text L_FIREWALL_032)"
        echo -e "$(tr_text L_FIREWALL_033)"
        echo -e "$(tr_text L_FIREWALL_034)"
        echo -e "$(tr_text L_FIREWALL_035)"
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

# ====== ПОДМЕНЮ 3: Network & Ports ======
submenu_network() {
    port_management
}

# port_apply open|close ПОРТ tcp|udp|both [описание] — без вопросов, для rw-scripts ports и скриптов.
# Коды: 0 ок, 1 ошибка файрвола, 2 файрвол не найден, 3 неверный порт или протокол.
port_apply() {
    local action="${1:-}" port="${2:-}" proto="${3:-}" desc="${4:-via CLI}" fw p protos
    fw=$(detect_firewall)
    [ "$fw" != "none" ] || return 2
    [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ] || return 3
    case "$proto" in
        tcp|udp) protos="$proto" ;;
        both)    protos="tcp udp" ;;
        *)       return 3 ;;
    esac
    case "$action" in open|close) ;; *) return 3 ;; esac
    init_ports_file
    ensure_jq || return 1

    for p in $protos; do
        case "$fw:$action" in
            ufw:open)          $SUDO ufw allow "$port/$p" >/dev/null ;;
            ufw:close)         $SUDO ufw delete allow "$port/$p" >/dev/null ;;
            firewalld:open)    $SUDO firewall-cmd --permanent --add-port="$port/$p" >/dev/null ;;
            firewalld:close)   $SUDO firewall-cmd --permanent --remove-port="$port/$p" >/dev/null ;;
            iptables:open)     $SUDO iptables -A INPUT -p "$p" --dport "$port" -j ACCEPT ;;
            iptables:close)    $SUDO iptables -D INPUT -p "$p" --dport "$port" -j ACCEPT ;;
        esac || return 1
    done

    [ "$fw" = "firewalld" ] && { $SUDO firewall-cmd --reload >/dev/null || return 1; }
    if [ "$fw" = "iptables" ] && command -v netfilter-persistent >/dev/null 2>&1; then
        $SUDO netfilter-persistent save >/dev/null || return 1
    fi

    for p in $protos; do
        if [ "$action" = "open" ]; then
            add_port_to_json "$port" "$p" "$desc" || return 1
        else
            remove_port_from_json "$port" "$p" || return 1
        fi
    done
    return 0
}
