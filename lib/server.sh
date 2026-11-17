#!/bin/bash
# lib/server.sh — Настройка сервера: SSH-порт, Zapret
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

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

    echo -e "$(tr_text L_SERVER_001 "${current_port}")"
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
        $SUDO sed -i "s/^Port .*/Port $new_port/" "$sshd_config"
    elif grep -qE "^#Port " "$sshd_config" 2>/dev/null; then
        $SUDO sed -i "s/^#Port .*/Port $new_port/" "$sshd_config"
    else
        echo "Port $new_port" | $SUDO tee -a "$sshd_config" > /dev/null
    fi

    # Открываем новый порт в firewall
    local firewall
    firewall=$(detect_firewall)
    case $firewall in
        ufw)
            $SUDO ufw allow "$new_port"/tcp >/dev/null 2>&1
            echo -e "$(tr_text L_SERVER_002 "$new_port")"
            ;;
        firewalld)
            $SUDO firewall-cmd --permanent --add-port="$new_port"/tcp >/dev/null 2>&1
            $SUDO firewall-cmd --reload >/dev/null 2>&1
            echo -e "$(tr_text L_SERVER_003 "$new_port")"
            ;;
        iptables)
            $SUDO iptables -A INPUT -p tcp --dport "$new_port" -j ACCEPT 2>/dev/null
            echo -e "$(tr_text L_SERVER_004 "$new_port")"
            ;;
    esac

    # Перезапускаем SSH
    echo -e "${BLUE}$(tr_text SSH_RESTART)${NC}"
    if $SUDO systemctl restart sshd 2>/dev/null || $SUDO systemctl restart ssh 2>/dev/null; then
        echo
        echo -e "${GREEN}✅ $(tr_text SSH_CHANGED) ${CYAN}${new_port}${NC}"
        echo
        echo -e "$(tr_text L_SERVER_005)"
        echo -e "  ${YELLOW}ssh -p ${new_port} $(whoami)@<your_server_ip>${NC}"
    else
        echo -e "${RED}❌ $(tr_text SSH_FAIL)${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

install_zapret() {
    echo -e "${BLUE}🛡️  $(tr_text ZAPRET_INSTALLING)${NC}"
    echo
    if run_remote_script --sh https://raw.githubusercontent.com/IndeecFOX/z4r/4/z4r; then
        echo
        echo -e "${GREEN}✅ $(tr_text ZAPRET_DONE)${NC}"
    else
        echo
        echo -e "${RED}❌ $(tr_text ZAPRET_FAIL)${NC}"
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}
