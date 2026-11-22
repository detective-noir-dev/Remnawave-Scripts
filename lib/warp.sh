#!/bin/bash
# lib/warp.sh — Cloudflare WARP
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

# Запускает команду под крутилкой, вывод скрыт; при ошибке показывает хвост лога
_run_spinner() {
    local log rc spinner_pid
    log=$(mktemp)
    loading_bar &
    spinner_pid=$!
    "$@" >"$log" 2>&1
    rc=$?
    kill "$spinner_pid" >/dev/null 2>&1
    wait "$spinner_pid" 2>/dev/null
    tput cnorm
    printf "\r%*s\r" 40 ""
    [ $rc -ne 0 ] && tail -n 15 "$log"
    rm -f "$log"
    return $rc
}

_warp_prepare_repo() {
    apt-get update -y \
        && apt-get install -y curl gnupg2 apt-transport-https lsb-release ca-certificates \
        && curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor -o /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg \
        && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" \
            > /etc/apt/sources.list.d/cloudflare-client.list \
        && apt-get update -y
}

_warp_configure() {
    warp-cli --accept-tos registration new \
        && warp-cli --accept-tos proxy port "$1" \
        && warp-cli --accept-tos mode proxy
}

_warp_connect_wait() {
    timeout 15 warp-cli --accept-tos connect && sleep 3
}

# Страна выхода через Cloudflare trace (без лимитов, возвращает код, напр. "NL")
_warp_country() {
    curl --socks5 "127.0.0.1:$1" -s -m 10 https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null \
        | sed -n 's/^loc=\([A-Z]\{2\}\)$/\1/p'
}

# ====== УСТАНОВКА CLOUDFLARE WARP ======
install_warp() {
    echo -e "${BLUE}☁️  $(tr_text WARP_INSTALLING)${NC}"
    echo

    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ $(tr_text WARP_ROOT_REQUIRED)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    # os-release читаем в подоболочке: иначе он перезапишет глобальный VERSION версией ОС
    local os_id
    # shellcheck disable=SC1091
    os_id=$([ -f /etc/os-release ] && . /etc/os-release && echo "$ID")
    if [[ "$os_id" != "ubuntu" && "$os_id" != "debian" ]]; then
        echo -e "${RED}❌ $(tr_text WARP_OS_UNSUPPORTED)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi

    local warp_port
    while true; do
        echo -e "${BLUE}$(tr_text WARP_PORT_PROMPT)${NC}"
        read -rp "> " warp_port
        warp_port="${warp_port:-40000}"
        if [[ "$warp_port" =~ ^[0-9]+$ ]] && (( warp_port >= 1 && warp_port <= 65535 )); then
            break
        fi
        echo -e "${RED}$(tr_text WARP_PORT_INVALID)${NC}"
    done

    export DEBIAN_FRONTEND=noninteractive

    _run_spinner _warp_prepare_repo || {
        echo -e "${RED}❌ $(tr_text WARP_REPO_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    }

    _run_spinner apt-get install -y cloudflare-warp || {
        echo -e "${RED}❌ $(tr_text WARP_PKG_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    }

    _run_spinner _warp_configure "$warp_port" || {
        echo -e "${RED}❌ $(tr_text WARP_CONFIG_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    }

    _run_spinner _warp_connect_wait || {
        echo -e "${RED}❌ $(tr_text WARP_CONNECT_FAIL)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    }

    local warp_ip country
    warp_ip=$(curl --socks5 "127.0.0.1:$warp_port" -s -m 10 https://ifconfig.me)
    country=$(_warp_country "$warp_port")

    echo
    echo -e "${GREEN}✅ $(tr_text WARP_DONE)${NC}"
    echo -e "  ${BOLD}$(tr_text WARP_PORT_LABEL):${NC} $warp_port"
    [ -n "$warp_ip" ] && echo -e "  ${BOLD}$(tr_text WARP_IP_LABEL):${NC} $warp_ip"
    [ -n "$country" ] && echo -e "  ${BOLD}$(tr_text WARP_COUNTRY_LABEL):${NC} $country"
    echo
    echo -e "${BOLD}${CYAN}▶ $(tr_text WARP_CMDS):${NC}"
    echo -e "  ${BOLD}${YELLOW}warp-cli status${NC} | ${BOLD}${YELLOW}warp-cli disconnect${NC} | ${BOLD}${YELLOW}warp-cli connect${NC} | ${BOLD}${YELLOW}warp-cli settings list${NC}"
    echo -e "  ${BOLD}${GREEN}export ALL_PROXY=socks5://127.0.0.1:$warp_port${NC}"

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

_warp_installed() {
    if ! command -v warp-cli >/dev/null 2>&1; then
        echo -e "${RED}❌ $(tr_text WARP_NOT_INSTALLED)${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return 1
    fi
}

_warp_is_connected() { warp-cli --accept-tos status 2>/dev/null | grep -q "Connected"; }

# ====== СТАТУС CLOUDFLARE WARP ======
warp_status() {
    _warp_installed || return 1
    local status_output
    status_output=$(warp-cli --accept-tos status 2>/dev/null)

    if echo "$status_output" | grep -q "Connected"; then
        echo -e "${GREEN}✅ $(tr_text WARP_STATUS_OK)${NC}"
        local port warp_ip country
        port=$(warp-cli --accept-tos settings list 2>/dev/null | grep "WarpProxy on port" | awk '{print $NF}')
        echo
        if [ -n "$port" ]; then
            warp_ip=$(curl --socks5 "127.0.0.1:$port" -s -m 10 https://ifconfig.me)
            country=$(_warp_country "$port")
            echo -e "  ${BOLD}$(tr_text WARP_PORT_LABEL):${NC} $port"
            [ -n "$warp_ip" ] && echo -e "  ${BOLD}$(tr_text WARP_IP_LABEL):${NC} $warp_ip"
            [ -n "$country" ] && echo -e "  ${BOLD}$(tr_text WARP_COUNTRY_LABEL):${NC} $country"
        fi
    else
        echo -e "${RED}❌ $(tr_text WARP_STATUS_BAD)${NC}"
        echo "$status_output"
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== ОТКЛЮЧЕНИЕ CLOUDFLARE WARP ======
warp_disconnect() {
    _warp_installed || return 1
    if _warp_is_connected; then
        if warp-cli --accept-tos disconnect >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $(tr_text WARP_DISCONNECTED)${NC}"
        else
            echo -e "${RED}❌ $(tr_text WARP_CONNECT_FAIL)${NC}"
        fi
    else
        echo -e "${YELLOW}ℹ️  $(tr_text WARP_ALREADY_OFF)${NC}"
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== ВКЛЮЧЕНИЕ CLOUDFLARE WARP ======
warp_connect() {
    _warp_installed || return 1
    if _warp_is_connected; then
        echo -e "${YELLOW}ℹ️  $(tr_text WARP_ALREADY_ON)${NC}"
    elif warp-cli --accept-tos connect >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $(tr_text WARP_CONNECTED)${NC}"
    else
        echo -e "${RED}❌ $(tr_text WARP_CONNECT_FAIL)${NC}"
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== УДАЛЕНИЕ CLOUDFLARE WARP ======
uninstall_warp() {
    _warp_installed || return 1
    read -rp "$(tr_text WARP_UNINSTALL_CONFIRM) " ans
    if [[ ! "$ans" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}$(tr_text WARP_CANCELLED)${NC}"
        sleep 1
        return 0
    fi

    echo -e "${BLUE}$(tr_text WARP_UNINSTALLING)${NC}"
    _warp_is_connected && warp-cli --accept-tos disconnect >/dev/null 2>&1
    warp-cli --accept-tos registration delete >/dev/null 2>&1
    if $SUDO apt-get purge -y cloudflare-warp >/dev/null 2>&1 && \
       $SUDO apt-get autoremove -y >/dev/null 2>&1 && \
       $SUDO rm -f /etc/apt/sources.list.d/cloudflare-client.list /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg; then
        echo -e "${GREEN}✅ $(tr_text WARP_UNINSTALLED)${NC}"
    else
        echo -e "${RED}❌ $(tr_text WARP_UNINSTALL_FAIL)${NC}"
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== ПОДМЕНЮ: CLOUDFLARE WARP ======
submenu_warp() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text SUB_WARP)"

        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_WARP_INSTALL)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_WARP_STATUS)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text SUB_WARP_DISCONNECT)"
        echo -e "  ${YELLOW}4)${NC} $(tr_text SUB_WARP_CONNECT)"
        echo -e "  ${YELLOW}5)${NC} $(tr_text SUB_WARP_UNINSTALL)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice

        case $choice in
            1) show_banner; install_warp ;;
            2) show_banner; warp_status ;;
            3) show_banner; warp_disconnect ;;
            4) show_banner; warp_connect ;;
            5) show_banner; uninstall_warp ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}
