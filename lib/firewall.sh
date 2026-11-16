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
    
    echo -e "${YELLOW}⚙️  'jq' не установлен. Устанавливаю...${NC}"
    loading_bar & pid=$!
    
    if ! pkg_mgr >/dev/null; then
        kill $pid >/dev/null 2>&1; tput cnorm
        echo -e "\r${RED}❌ Не удалось определить пакетный менеджер.${NC}"
        return 1
    fi
    pkg_install jq &>/dev/null
    
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
                $SUDO ufw allow "$port"/tcp &>/dev/null
                $SUDO ufw allow "$port"/udp &>/dev/null
                add_port_to_json "$port" "tcp" "$description"
                add_port_to_json "$port" "udp" "$description"
            else
                $SUDO ufw allow "$port"/"$protocol" &>/dev/null
                add_port_to_json "$port" "$protocol" "$description"
            fi
            ;;
        firewalld)
            if [ "$protocol" = "both" ]; then
                $SUDO firewall-cmd --permanent --add-port="$port"/tcp &>/dev/null
                $SUDO firewall-cmd --permanent --add-port="$port"/udp &>/dev/null
                add_port_to_json "$port" "tcp" "$description"
                add_port_to_json "$port" "udp" "$description"
            else
                $SUDO firewall-cmd --permanent --add-port="$port"/"$protocol" &>/dev/null
                add_port_to_json "$port" "$protocol" "$description"
            fi
            $SUDO firewall-cmd --reload &>/dev/null
            ;;
        iptables)
            if [ "$protocol" = "both" ]; then
                $SUDO iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
                $SUDO iptables -A INPUT -p udp --dport "$port" -j ACCEPT
                add_port_to_json "$port" "tcp" "$description"
                add_port_to_json "$port" "udp" "$description"
            else
                $SUDO iptables -A INPUT -p "$protocol" --dport "$port" -j ACCEPT
                add_port_to_json "$port" "$protocol" "$description"
            fi
            command -v netfilter-persistent &>/dev/null && $SUDO netfilter-persistent save &>/dev/null
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
                $SUDO ufw delete allow "$port"/tcp &>/dev/null
                $SUDO ufw delete allow "$port"/udp &>/dev/null
                remove_port_from_json "$port" "tcp"
                remove_port_from_json "$port" "udp"
            else
                $SUDO ufw delete allow "$port"/"$protocol" &>/dev/null
                remove_port_from_json "$port" "$protocol"
            fi
            ;;
        firewalld)
            if [ "$protocol" = "both" ]; then
                $SUDO firewall-cmd --permanent --remove-port="$port"/tcp &>/dev/null
                $SUDO firewall-cmd --permanent --remove-port="$port"/udp &>/dev/null
                remove_port_from_json "$port" "tcp"
                remove_port_from_json "$port" "udp"
            else
                $SUDO firewall-cmd --permanent --remove-port="$port"/"$protocol" &>/dev/null
                remove_port_from_json "$port" "$protocol"
            fi
            $SUDO firewall-cmd --reload &>/dev/null
            ;;
        iptables)
            if [ "$protocol" = "both" ]; then
                $SUDO iptables -D INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null
                $SUDO iptables -D INPUT -p udp --dport "$port" -j ACCEPT 2>/dev/null
                remove_port_from_json "$port" "tcp"
                remove_port_from_json "$port" "udp"
            else
                $SUDO iptables -D INPUT -p "$protocol" --dport "$port" -j ACCEPT 2>/dev/null
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
    local exists=$(jq -r --arg p "$port" --arg pr "$protocol" '.[] | select(.port == $p and .protocol == $pr) | .description' "$PORTS_FILE")
    
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

# ====== ПОДМЕНЮ 3: Network & Ports ======
submenu_network() {
    port_management
}
