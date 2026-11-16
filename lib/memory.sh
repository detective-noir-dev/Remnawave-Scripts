#!/bin/bash
# lib/memory.sh — Swap и ZRAM
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

_mem_swap_status() {
    local swp; swp=$(free -m 2>/dev/null | awk '/^Swap:/{print $2}')
    local has_zram; has_zram=$(lsblk 2>/dev/null | grep -i zram)
    local has_file; has_file=$(swapon --show --noheadings 2>/dev/null | grep -i swapfile)
    if [ -n "$has_zram" ] && [ -n "$has_file" ]; then
        echo -e "${GREEN}[ГИБРИД: ZRAM + Disk Swap]${NC}"
    elif [ -n "$has_zram" ]; then
        echo -e "${GREEN}[ZRAM: ${swp} MB]${NC}"
    elif [ -n "$swp" ] && [ "$swp" != "0" ]; then
        echo -e "${YELLOW}[Disk Swap: ${swp} MB]${NC}"
    else
        echo -e "${RED}[ВЫКЛЮЧЕН]${NC}"
    fi
}

_mem_show_status() {
    show_banner
    print_submenu_header "$(tr_text MEM_SHOW_STATUS)"
    local mt mu mc ma st su sf
    mt=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}')
    mu=$(free -m 2>/dev/null | awk '/^Mem:/{print $3}')
    mc=$(free -m 2>/dev/null | awk '/^Mem:/{print $6}')
    ma=$(free -m 2>/dev/null | awk '/^Mem:/{print $7}')
    st=$(free -m 2>/dev/null | awk '/^Swap:/{print $2}')
    su=$(free -m 2>/dev/null | awk '/^Swap:/{print $3}')
    sf=$(free -m 2>/dev/null | awk '/^Swap:/{print $4}')
    echo -e "  ${CYAN}💻 Оперативная память (RAM):${NC}"
    echo -e "    └─ Всего:        ${GREEN}${mt} MB${NC}"
    echo -e "    └─ Используется: ${YELLOW}${mu} MB${NC}"
    echo -e "    └─ Кэш/Буферы:  ${BLUE}${mc} MB${NC}"
    echo -e "    └─ Свободно:     ${GREEN}${ma} MB${NC}"
    echo
    echo -e "  ${CYAN}💽 Файл подкачки (ZRAM / Swap):${NC}"
    if [ "${st:-0}" = "0" ]; then
        echo -e "    └─ ${RED}ВЫКЛЮЧЕН (рекомендуется включить ZRAM!)${NC}"
    else
        lsblk 2>/dev/null | grep -q zram \
            && echo -e "    └─ Тип: ${GREEN}ZRAM (сжатие в ОЗУ)${NC}" \
            || echo -e "    └─ Тип: ${YELLOW}Disk Swap${NC}"
        echo -e "    └─ Выделено:     ${GREEN}${st} MB${NC}"
        echo -e "    └─ Используется: ${RED}${su} MB${NC}"
        echo -e "    └─ Свободно:     ${GREEN}${sf} MB${NC}"
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

_mem_show_instructions() {
    show_banner
    print_submenu_header "$(tr_text MEM_INSTRUCTIONS)"
    echo -e "  ${CYAN}${BOLD}ZRAM vs Disk Swap:${NC}"
    echo -e "  ${GREEN}ZRAM${NC} — сжатие в ОЗУ, скорость = RAM. Идеален для VPN."
    echo -e "       Обязателен для серверов 1-2 ГБ!"
    echo -e "  ${YELLOW}Disk Swap${NC} — в 10-50× медленнее ZRAM. Только если ОЗУ < 512 МБ."
    echo
    echo -e "  ${CYAN}${BOLD}Лимиты памяти в docker-compose.yml (блок remnanode):${NC}"
    echo
    echo -e "  ${BOLD}▶ Сервер 1 ГБ RAM:${NC}"
    echo -e "${CYAN}    environment:
      - NODE_OPTIONS=--max-old-space-size=256
    deploy:
      resources:
        limits:
          memory: 768M${NC}"
    echo
    echo -e "  ${BOLD}▶ Сервер 2 ГБ RAM:${NC}"
    echo -e "${CYAN}    environment:
      - NODE_OPTIONS=--max-old-space-size=512
    deploy:
      resources:
        limits:
          memory: 1536M${NC}"
    echo
    echo -e "  ${BOLD}▶ Сервер 4+ ГБ RAM:${NC}"
    echo -e "${CYAN}    environment:
      - NODE_OPTIONS=--max-old-space-size=1024
    deploy:
      resources:
        limits:
          memory: 3072M${NC}"
    echo
    echo -e "  ${YELLOW}После изменений: docker compose down && docker compose up -d${NC}"
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

_mem_install_hybrid() {
    echo -e "${BLUE}Настройка гибридной памяти (ZRAM 50% + Disk Swap 2GB)...${NC}"
    _pkg_install zram-tools bc
    printf "ALGO=lz4\nPERCENT=50\nPRIORITY=100\n" | $SUDO tee /etc/default/zramswap >/dev/null
    $SUDO systemctl restart zramswap >/dev/null 2>&1
    $SUDO systemctl enable zramswap >/dev/null 2>&1
    if [ ! -f /swapfile ]; then
        echo -e "${BLUE}Создание Disk Swap 2GB (резервная страховка)...${NC}"
        $SUDO fallocate -l 2G /swapfile 2>/dev/null \
            || $SUDO dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
        $SUDO chmod 600 /swapfile
        $SUDO mkswap /swapfile >/dev/null 2>&1
        $SUDO swapon -p -2 /swapfile 2>/dev/null || $SUDO swapon /swapfile
        grep -qE '^/swapfile\s' /etc/fstab \
            || echo '/swapfile none swap sw,pri=-2 0 0' | $SUDO tee -a /etc/fstab >/dev/null
    fi
    echo -e "${GREEN}✅ Гибридная память: ZRAM (prio 100) + Swap (prio -2).${NC}"
}

_mem_install_zram() {
    local pct=$1
    echo -e "${BLUE}Установка ZRAM (${pct}%)...${NC}"
    $SUDO swapoff -a 2>/dev/null || true
    $SUDO rm -f /swapfile 2>/dev/null
    $SUDO sed -i '/^\/swapfile/d' /etc/fstab 2>/dev/null
    _pkg_install zram-tools bc
    printf "ALGO=lz4\nPERCENT=%s\nPRIORITY=100\n" "$pct" | $SUDO tee /etc/default/zramswap >/dev/null
    $SUDO systemctl restart zramswap >/dev/null 2>&1
    $SUDO systemctl enable zramswap >/dev/null 2>&1
    echo -e "${GREEN}✅ ZRAM ${pct}% активирован!${NC}"
}

_mem_install_swap() {
    local sz=$1
    echo -e "${BLUE}Создание Disk Swap ${sz}GB...${NC}"
    $SUDO systemctl stop zramswap 2>/dev/null || true
    $SUDO apt-get remove --purge zram-tools -y >/dev/null 2>&1 || true
    $SUDO swapoff -a 2>/dev/null || true
    $SUDO rm -f /swapfile 2>/dev/null
    $SUDO fallocate -l "${sz}G" /swapfile \
        || $SUDO dd if=/dev/zero of=/swapfile bs=1M count=$(( sz * 1024 )) status=none
    $SUDO chmod 600 /swapfile
    $SUDO mkswap /swapfile >/dev/null 2>&1
    $SUDO swapon /swapfile
    grep -qE '^/swapfile\s' /etc/fstab \
        || echo '/swapfile none swap sw 0 0' | $SUDO tee -a /etc/fstab >/dev/null
    echo -e "${GREEN}✅ Disk Swap ${sz}GB создан!${NC}"
}

_mem_remove_all() {
    echo -e "${BLUE}Удаление ZRAM и Disk Swap...${NC}"
    $SUDO systemctl stop zramswap 2>/dev/null || true
    $SUDO systemctl disable zramswap 2>/dev/null || true
    $SUDO apt-get remove --purge zram-tools -y >/dev/null 2>&1 || true
    $SUDO swapoff -a 2>/dev/null || true
    $SUDO rm -f /swapfile 2>/dev/null
    $SUDO sed -i '/^\/swapfile/d' /etc/fstab 2>/dev/null
    echo -e "${GREEN}✅ ZRAM и Swap полностью удалены.${NC}"
}

submenu_memory() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_MEMORY)"

        local ram_kb; ram_kb=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')
        local ram_mb=$(( ${ram_kb:-0} / 1024 ))
        local ram_gb=$(( (ram_mb + 512) / 1024 ))
        local rec_zram rec_swap
        if   [ "$ram_mb" -le 1024 ]; then rec_zram=60; rec_swap=2
        elif [ "$ram_mb" -le 2048 ]; then rec_zram=50; rec_swap=2
        elif [ "$ram_mb" -le 4096 ]; then rec_zram=40; rec_swap=4
        else                              rec_zram=25; rec_swap=4; fi

        echo -e "  ${DIM}RAM: ${GREEN}${ram_gb} GB (${ram_mb} MB)${NC}  |  Swap: $(_mem_swap_status)"
        echo
        echo -e "  ${YELLOW}1)${NC} $(tr_text MEM_HYBRID)"
        echo -e "     ${DIM}└ Рекомендовано: ZRAM ${rec_zram}% + Swap ${rec_swap}GB${NC}"
        echo -e "  ${YELLOW}2)${NC} $(tr_text MEM_ZRAM_ONLY)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text MEM_SWAP_ONLY)"
        echo -e "  ${DIM}──────────────────────────────${NC}"
        echo -e "  ${YELLOW}4)${NC} $(tr_text MEM_REMOVE_ALL)"
        echo -e "  ${YELLOW}5)${NC} $(tr_text MEM_SHOW_STATUS)"
        echo -e "  ${YELLOW}6)${NC} $(tr_text MEM_INSTRUCTIONS)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        case $choice in
            1) show_banner; _mem_install_hybrid; read -rp "$(tr_text PRESS_ENTER)" ;;
            2) show_banner
               echo -e "${YELLOW}$(tr_text MEM_ZRAM_PERCENT)${NC}"
               read -rp "> " pct; pct=${pct:-60}
               [[ "$pct" =~ ^[0-9]+$ ]] || { echo -e "${RED}$(tr_text ERR_NUMBER)${NC}"; sleep 1; continue; }
               _mem_install_zram "$pct"; read -rp "$(tr_text PRESS_ENTER)" ;;
            3) show_banner
               echo -e "${YELLOW}$(tr_text MEM_SWAP_SIZE)${NC}"
               read -rp "> " sz; sz=${sz:-2}
               [[ "$sz" =~ ^[0-9]+$ ]] || { echo -e "${RED}$(tr_text ERR_NUMBER)${NC}"; sleep 1; continue; }
               _mem_install_swap "$sz"; read -rp "$(tr_text PRESS_ENTER)" ;;
            4) show_banner; _mem_remove_all; read -rp "$(tr_text PRESS_ENTER)" ;;
            5) _mem_show_status ;;
            6) _mem_show_instructions ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}
