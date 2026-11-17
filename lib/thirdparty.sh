#!/bin/bash
# lib/thirdparty.sh — Сторонние скрипты (eGames, Reshala, multitest)
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

# ====== УСТАНОВКА REMNAWAVE ОТ EGAMES ======
install_egames_remnawave() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    🌐 $(tr_text SUB_EGAMES_RW)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}$(tr_text EGAMES_INSTALLING)${NC}"
    echo -e "${DIM}Script: eGamesAPI/remnawave-reverse-proxy${NC}"
    echo

    run_remote_script https://raw.githubusercontent.com/eGamesAPI/remnawave-reverse-proxy/refs/heads/main/install_remnawave.sh
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ $(tr_text EGAMES_DONE)${NC}"
        echo
        # Применяем bashrc в текущем shell
        # shellcheck disable=SC1090
        [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" 2>/dev/null || true
        echo -e "${YELLOW}$(tr_text BASHRC_RELOAD)${NC}"
    else
        echo -e "${RED}❌ $(tr_text EGAMES_FAIL)${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== УСТАНОВКА RESHALA ======
install_reshala() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    🤖 $(tr_text SUB_RESHALA)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}$(tr_text RESHALA_INSTALLING)${NC}"
    echo -e "${DIM}Script: DonMatteoVPN/Reshala-Remnawave-Bedolaga${NC}"
    echo

    run_remote_script https://raw.githubusercontent.com/DonMatteoVPN/Reshala-Remnawave-Bedolaga/main/install.sh
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ $(tr_text RESHALA_DONE)${NC}"
        echo
        # Применяем bashrc в текущем shell
        # shellcheck disable=SC1090
        [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" 2>/dev/null || true
        echo -e "${YELLOW}$(tr_text BASHRC_RELOAD)${NC}"
        echo
        echo -e "$(tr_text L_THIRDPARTY_001)"
        sleep 1
        if command -v reshala >/dev/null 2>&1; then
            reshala
        else
            echo -e "$(tr_text L_THIRDPARTY_002)"
        fi
    else
        echo -e "${RED}❌ $(tr_text RESHALA_FAIL)${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== УСТАНОВКА MULTITEST ======
install_multitest() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    $(tr_text SUB_MULTITEST)${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}$(tr_text MULTITEST_INSTALLING)${NC}"
    echo -e "${DIM}Script: saveksme/multitest${NC}"
    echo

    install_remote_script https://raw.githubusercontent.com/saveksme/multitest/master/multitest.sh /usr/local/bin/multitest
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ $(tr_text MULTITEST_DONE)${NC}"
        echo
        echo -e "$(tr_text L_THIRDPARTY_003)"
        sleep 1
        if [ -x /usr/local/bin/multitest ]; then
            /usr/local/bin/multitest
        else
            echo -e "$(tr_text L_THIRDPARTY_004)"
        fi
    else
        echo -e "${RED}❌ $(tr_text MULTITEST_FAIL)${NC}"
    fi

    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== ПОДМЕНЮ: СТОРОННИЕ СКРИПТЫ ======
submenu_thirdparty() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_THIRDPARTY)"

        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_EGAMES_RW)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_RESHALA)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text SUB_MULTITEST)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice

        case $choice in
            1) show_banner; install_egames_remnawave ;;
            2) show_banner; install_reshala ;;
            3) show_banner; install_multitest ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}
