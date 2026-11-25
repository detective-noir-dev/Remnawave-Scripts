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

    # Сохраняем резервную копию конфига
    local sshd_backup="${sshd_config}.bak.$$" sshd_bin
    $SUDO cp -a "$sshd_config" "$sshd_backup" 2>/dev/null || {
        echo -e "${RED}❌ $(tr_text SSH_BACKUP_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    }

    # Меняем порт в конфиге
    if grep -qE "^Port " "$sshd_config" 2>/dev/null; then
        $SUDO sed -i "s/^Port .*/Port $new_port/" "$sshd_config" || {
            $SUDO cp -a "$sshd_backup" "$sshd_config" 2>/dev/null
            $SUDO rm -f "$sshd_backup"
            echo -e "${RED}❌ $(tr_text SSH_CONFIG_INVALID)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 1
        }
    elif grep -qE "^#Port " "$sshd_config" 2>/dev/null; then
        $SUDO sed -i "s/^#Port .*/Port $new_port/" "$sshd_config" || {
            $SUDO cp -a "$sshd_backup" "$sshd_config" 2>/dev/null
            $SUDO rm -f "$sshd_backup"
            echo -e "${RED}❌ $(tr_text SSH_CONFIG_INVALID)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 1
        }
    else
        echo "Port $new_port" | $SUDO tee -a "$sshd_config" > /dev/null || {
            $SUDO cp -a "$sshd_backup" "$sshd_config" 2>/dev/null
            $SUDO rm -f "$sshd_backup"
            echo -e "${RED}❌ $(tr_text SSH_CONFIG_INVALID)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 1
        }
    fi

    # Проверяем синтаксис конфига перед перезапуском
    sshd_bin=$(command -v sshd 2>/dev/null || echo /usr/sbin/sshd)
    if ! $SUDO "$sshd_bin" -t -f "$sshd_config" 2>/dev/null; then
        echo -e "${RED}❌ $(tr_text SSH_CONFIG_INVALID)${NC}"
        $SUDO cp -a "$sshd_backup" "$sshd_config" 2>/dev/null
        $SUDO rm -f "$sshd_backup"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
    # Открываем новый порт в firewall
    local firewall
    local firewall_ok=1
    firewall=$(detect_firewall)
    case $firewall in
        ufw)
            $SUDO ufw allow "$new_port"/tcp >/dev/null 2>&1 || firewall_ok=0
            echo -e "$(tr_text L_SERVER_002 "$new_port")"
            ;;
        firewalld)
            $SUDO firewall-cmd --permanent --add-port="$new_port"/tcp >/dev/null 2>&1 && \
                $SUDO firewall-cmd --reload >/dev/null 2>&1 || firewall_ok=0
            echo -e "$(tr_text L_SERVER_003 "$new_port")"
            ;;
        iptables)
            $SUDO iptables -A INPUT -p tcp --dport "$new_port" -j ACCEPT 2>/dev/null || firewall_ok=0
            echo -e "$(tr_text L_SERVER_004 "$new_port")"
            ;;
    esac
    if [ "$firewall_ok" -ne 1 ]; then
        $SUDO cp -a "$sshd_backup" "$sshd_config" 2>/dev/null
        $SUDO rm -f "$sshd_backup"
        echo -e "${RED}❌ $(tr_text SSH_FIREWALL_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    # Перезапускаем SSH
    echo -e "${BLUE}$(tr_text SSH_RESTART)${NC}"
    if $SUDO systemctl restart sshd 2>/dev/null || $SUDO systemctl restart ssh 2>/dev/null; then
        $SUDO rm -f "$sshd_backup"
        echo
        echo -e "${GREEN}✅ $(tr_text SSH_CHANGED) ${CYAN}${new_port}${NC}"
        echo
        echo -e "$(tr_text L_SERVER_005)"
        echo -e "  ${YELLOW}ssh -p ${new_port} $(whoami)@<your_server_ip>${NC}"
    else
        $SUDO cp -a "$sshd_backup" "$sshd_config" 2>/dev/null
        $SUDO systemctl restart sshd 2>/dev/null || $SUDO systemctl restart ssh 2>/dev/null
        $SUDO rm -f "$sshd_backup"
        echo -e "${RED}❌ $(tr_text SSH_FAIL)${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== SSH КЛЮЧИ И АУТЕНТИФИКАЦИЯ ======
_ssh_target_user() {
    printf '%s\n' "${SUDO_USER:-${USER:-$(id -un)}}"
}

_ssh_authorized_key_count() {
    local auth_keys=$1

    $SUDO awk '
        /^[[:space:]]*($|#)/ { next }
        {
            for (i = 1; i < NF; i++) {
                if ($i ~ /^(ssh-ed25519|ssh-rsa|ssh-dss|ecdsa-sha2-nistp(256|384|521)|sk-ssh-ed25519@openssh\.com|sk-ecdsa-sha2-nistp256@openssh\.com)$/ \
                    && $(i + 1) ~ /^[A-Za-z0-9+\/=]+$/) {
                    count++
                    break
                }
            }
        }
        END { print count + 0 }
    ' "$auth_keys"
}

_ssh_restart_service() {
    $SUDO systemctl restart sshd 2>/dev/null || $SUDO systemctl restart ssh 2>/dev/null
}

show_ssh_config() {
    local sshd_config="/etc/ssh/sshd_config" sshd_backup="/etc/ssh/sshd_config.bak.$$" editor sshd_bin

    if ! $SUDO test -f "$sshd_config"; then
        echo -e "${RED}❌ $(tr_text SSH_CONFIG_READ_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    editor="${SUDO_EDITOR:-${VISUAL:-${EDITOR:-}}}"
    if [ -n "$editor" ]; then
        if ! command -v "${editor%% *}" >/dev/null 2>&1; then
            editor=""
        fi
    fi
    if [ -z "$editor" ]; then
        for candidate in nano vim vi; do
            if command -v "$candidate" >/dev/null 2>&1; then
                editor=$candidate
                break
            fi
        done
    fi
    if [ -z "$editor" ]; then
        echo -e "${RED}❌ $(tr_text SSH_EDITOR_NOT_FOUND)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    if ! $SUDO cp -a "$sshd_config" "$sshd_backup"; then
        echo -e "${RED}❌ $(tr_text SSH_BACKUP_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    echo -e "${CYAN}$(tr_text SSH_CONFIG_EDITING)${NC}"
    if [[ "$editor" == *" "* ]]; then
        # shellcheck disable=SC2086
        $SUDO $editor "$sshd_config"
    else
        $SUDO "$editor" "$sshd_config"
    fi
    if [ "$?" -ne 0 ]; then
        $SUDO cp -a "$sshd_backup" "$sshd_config"
        $SUDO rm -f "$sshd_backup"
        echo -e "${RED}❌ $(tr_text SSH_CONFIG_EDIT_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    sshd_bin=$(command -v sshd 2>/dev/null || echo /usr/sbin/sshd)
    if ! $SUDO "$sshd_bin" -t -f "$sshd_config" 2>/dev/null; then
        $SUDO cp -a "$sshd_backup" "$sshd_config"
        $SUDO rm -f "$sshd_backup"
        echo -e "${RED}❌ $(tr_text SSH_CONFIG_INVALID)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    if ! _ssh_restart_service; then
        $SUDO cp -a "$sshd_backup" "$sshd_config"
        _ssh_restart_service
        $SUDO rm -f "$sshd_backup"
        echo -e "${RED}❌ $(tr_text SSH_CONFIG_RESTART_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    $SUDO rm -f "$sshd_backup"
    echo -e "${GREEN}✅ $(tr_text SSH_CONFIG_SAVED)${NC}"
    read -rp "$(tr_text PRESS_ENTER)"
}

add_ssh_ed25519_key() {
    local target_user home_dir auth_keys public_key key_count ans tmp_keys public_key_data
    target_user=$(_ssh_target_user)
    home_dir=$(getent passwd "$target_user" 2>/dev/null | cut -d: -f6)

    if [ -z "$home_dir" ] || [ ! -d "$home_dir" ]; then
        echo -e "${RED}❌ $(tr_text SSH_USER_HOME_FAIL "$target_user")${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    echo -e "${CYAN}$(tr_text SSH_KEY_TARGET "$target_user")${NC}"
    echo -e "${BLUE}$(tr_text SSH_KEY_PROMPT)${NC}"
    read -r public_key

    if ! printf '%s\n' "$public_key" | awk 'NF >= 2 && $1 == "ssh-ed25519" && $2 ~ /^[A-Za-z0-9+\/=]+$/ { found = 1 } END { exit !found }'; then
        echo -e "${RED}❌ $(tr_text SSH_KEY_INVALID)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    if ! printf '%s\n' "$public_key" | ssh-keygen -lf - >/dev/null 2>&1; then
        echo -e "${RED}❌ $(tr_text SSH_KEY_INVALID)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    auth_keys="$home_dir/.ssh/authorized_keys"
    key_count=0
    if $SUDO test -f "$auth_keys"; then
        key_count=$($SUDO awk '$1 == "ssh-ed25519" { n++ } END { print n+0 }' "$auth_keys")
        public_key_data=$(printf '%s\n' "$public_key" | awk '{print $2}')
        if $SUDO awk -v key_data="$public_key_data" '$1 == "ssh-ed25519" && $2 == key_data { found = 1 } END { exit !found }' "$auth_keys"; then
            echo -e "${GREEN}$(tr_text SSH_KEY_ALREADY_PRESENT)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 0
        fi
    fi
    if [ "$key_count" -gt 0 ]; then
        echo -e "${YELLOW}$(tr_text SSH_KEY_EXISTS "$key_count")${NC}"
        echo -e "${YELLOW}$(tr_text SSH_KEY_REPLACE_CONFIRM)${NC}"
        read -r ans
        if [[ ! "$ans" =~ ^[YyДд]$ ]]; then
            echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 0
        fi
    fi

    if ! $SUDO install -d -m 700 -o "$target_user" -g "$(id -gn "$target_user")" "$home_dir/.ssh"; then
        echo -e "${RED}❌ $(tr_text SSH_KEY_ADD_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    if [ "$key_count" -gt 0 ]; then
        tmp_keys=$(mktemp)
        if $SUDO awk '$1 != "ssh-ed25519"' "$auth_keys" > "$tmp_keys" \
            && printf '%s\n' "$public_key" >> "$tmp_keys" \
            && $SUDO install -m 600 -o "$target_user" -g "$(id -gn "$target_user")" "$tmp_keys" "$auth_keys"; then
            rm -f "$tmp_keys"
            echo -e "${GREEN}✅ $(tr_text SSH_KEY_REPLACED)${NC}"
        else
            rm -f "$tmp_keys"
            echo -e "${RED}❌ $(tr_text SSH_KEY_ADD_FAIL)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 1
        fi
    elif printf '%s\n' "$public_key" | $SUDO tee -a "$auth_keys" >/dev/null \
        && $SUDO chown "$target_user":"$(id -gn "$target_user")" "$auth_keys" \
        && $SUDO chmod 600 "$auth_keys"; then
        echo -e "${GREEN}✅ $(tr_text SSH_KEY_ADDED)${NC}"
    else
        echo -e "${RED}❌ $(tr_text SSH_KEY_ADD_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    read -rp "$(tr_text PRESS_ENTER)"
}

disable_ssh_password_auth() {
    local target_user home_dir auth_keys sshd_config sshd_backup sshd_bin effective_auth key_count
    target_user=$(_ssh_target_user)
    sshd_config="/etc/ssh/sshd_config"
    sshd_bin=$(command -v sshd 2>/dev/null || echo /usr/sbin/sshd)
    if effective_auth=$($SUDO "$sshd_bin" -T -f "$sshd_config" 2>/dev/null); then
        if printf '%s\n' "$effective_auth" | grep -qx 'passwordauthentication no' \
            && printf '%s\n' "$effective_auth" | grep -qx 'kbdinteractiveauthentication no'; then
            echo -e "${GREEN}$(tr_text SSH_PASSWORD_ALREADY_DISABLED)${NC}"
            read -rp "$(tr_text PRESS_ENTER)"
            return 0
        fi
        if printf '%s\n' "$effective_auth" | grep -qx 'passwordauthentication no'; then
            echo -e "${YELLOW}$(tr_text SSH_PASSWORD_INTERACTIVE_ENABLED)${NC}"
        fi
    fi

    home_dir=$(getent passwd "$target_user" 2>/dev/null | cut -d: -f6)
    auth_keys="$home_dir/.ssh/authorized_keys"

    key_count=0
    if [ -n "$home_dir" ] && $SUDO test -f "$auth_keys"; then
        key_count=$(_ssh_authorized_key_count "$auth_keys")
    fi
    if [ "$key_count" -eq 0 ]; then
        echo -e "${RED}❌ $(tr_text SSH_PASSWORD_NO_KEY "$target_user")${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    echo -e "${RED}$(tr_text SSH_PASSWORD_WARN)${NC}"
    echo -e "${YELLOW}$(tr_text SSH_PASSWORD_CONFIRM)${NC}"
    read -r ans
    if [[ ! "$ans" =~ ^[YyДд]$ ]]; then
        echo -e "${YELLOW}$(tr_text CANCEL_DEL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 0
    fi

    sshd_backup="${sshd_config}.bak.$$"
    if ! $SUDO cp -a "$sshd_config" "$sshd_backup"; then
        echo -e "${RED}❌ $(tr_text SSH_BACKUP_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    if $SUDO sed -i -E \
        -e 's/^[[:space:]]*#?[[:space:]]*PasswordAuthentication[[:space:]]+.*/PasswordAuthentication no/' \
        -e 's/^[[:space:]]*#?[[:space:]]*KbdInteractiveAuthentication[[:space:]]+.*/KbdInteractiveAuthentication no/' \
        -e 's/^[[:space:]]*#?[[:space:]]*ChallengeResponseAuthentication[[:space:]]+.*/ChallengeResponseAuthentication no/' \
        "$sshd_config"; then
        $SUDO grep -qE '^[[:space:]]*PasswordAuthentication[[:space:]]+' "$sshd_config" \
            || echo 'PasswordAuthentication no' | $SUDO tee -a "$sshd_config" >/dev/null
        $SUDO grep -qE '^[[:space:]]*KbdInteractiveAuthentication[[:space:]]+' "$sshd_config" \
            || echo 'KbdInteractiveAuthentication no' | $SUDO tee -a "$sshd_config" >/dev/null
        $SUDO grep -qE '^[[:space:]]*ChallengeResponseAuthentication[[:space:]]+' "$sshd_config" \
            || echo 'ChallengeResponseAuthentication no' | $SUDO tee -a "$sshd_config" >/dev/null
    else
        $SUDO cp -a "$sshd_backup" "$sshd_config"
        $SUDO rm -f "$sshd_backup"
        echo -e "${RED}❌ $(tr_text SSH_CONFIG_INVALID)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    if ! $SUDO "$sshd_bin" -t -f "$sshd_config" 2>/dev/null \
        || ! $SUDO "$sshd_bin" -T -f "$sshd_config" 2>/dev/null | grep -qx 'passwordauthentication no' \
        || ! $SUDO "$sshd_bin" -T -f "$sshd_config" 2>/dev/null | grep -qx 'kbdinteractiveauthentication no' \
        || ! _ssh_restart_service; then
        $SUDO cp -a "$sshd_backup" "$sshd_config"
        _ssh_restart_service
        $SUDO rm -f "$sshd_backup"
        echo -e "${RED}❌ $(tr_text SSH_PASSWORD_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    $SUDO rm -f "$sshd_backup"
    echo -e "${GREEN}✅ $(tr_text SSH_PASSWORD_DISABLED)${NC}"
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
