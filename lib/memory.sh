#!/bin/bash
# lib/memory.sh — Swap и ZRAM
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

_mem_swap_status() {
    local swp; swp=$(free -m 2>/dev/null | awk '/^Swap:/{print $2}')
    local has_zram; has_zram=$(lsblk 2>/dev/null | grep -i zram)
    local has_file; has_file=$(swapon --show --noheadings 2>/dev/null | grep -i swapfile)
    if [ -n "$has_zram" ] && [ -n "$has_file" ]; then
        echo -e "$(tr_text L_MEMORY_001)"
    elif [ -n "$has_zram" ]; then
        echo -e "${GREEN}[ZRAM: ${swp} MB]${NC}"
    elif [ -n "$swp" ] && [ "$swp" != "0" ]; then
        echo -e "${YELLOW}[Disk Swap: ${swp} MB]${NC}"
    else
        echo -e "$(tr_text L_MEMORY_002)"
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
    echo -e "$(tr_text L_MEMORY_003)"
    echo -e "$(tr_text L_MEMORY_004 "${mt}")"
    echo -e "$(tr_text L_MEMORY_005 "${mu}")"
    echo -e "$(tr_text L_MEMORY_006 "${mc}")"
    echo -e "$(tr_text L_MEMORY_007 "${ma}")"
    echo
    echo -e "$(tr_text L_MEMORY_008)"
    if [ "${st:-0}" = "0" ]; then
        echo -e "$(tr_text L_MEMORY_009)"
    else
        lsblk 2>/dev/null | grep -q zram \
            && echo -e "$(tr_text L_MEMORY_010)" \
            || echo -e "$(tr_text L_MEMORY_011)"
        echo -e "$(tr_text L_MEMORY_012 "${st}")"
        echo -e "$(tr_text L_MEMORY_013 "${su}")"
        echo -e "$(tr_text L_MEMORY_014 "${sf}")"
    fi
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

_mem_show_instructions() {
    show_banner
    print_submenu_header "$(tr_text MEM_INSTRUCTIONS)"
    echo -e "  ${CYAN}${BOLD}ZRAM vs Disk Swap:${NC}"
    echo -e "$(tr_text L_MEMORY_015)"
    echo -e "$(tr_text L_MEMORY_016)"
    echo -e "$(tr_text L_MEMORY_017)"
    echo
    echo -e "$(tr_text L_MEMORY_018)"
    echo
    echo -e "$(tr_text L_MEMORY_019)"
    echo -e "${CYAN}    environment:
      - NODE_OPTIONS=--max-old-space-size=256
    deploy:
      resources:
        limits:
          memory: 768M${NC}"
    echo
    echo -e "$(tr_text L_MEMORY_020)"
    echo -e "${CYAN}    environment:
      - NODE_OPTIONS=--max-old-space-size=512
    deploy:
      resources:
        limits:
          memory: 1536M${NC}"
    echo
    echo -e "$(tr_text L_MEMORY_021)"
    echo -e "${CYAN}    environment:
      - NODE_OPTIONS=--max-old-space-size=1024
    deploy:
      resources:
        limits:
          memory: 3072M${NC}"
    echo
    echo -e "$(tr_text L_MEMORY_022)"
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# _mem_setup_zram ПРОЦЕНТ — пакет, конфиг и запуск zramswap; любая ошибка видна по коду возврата
_mem_setup_zram() {
    local pct=$1
    _pkg_install zram-tools bc
    printf "ALGO=lz4\nPERCENT=%s\nPRIORITY=100\n" "$pct" | $SUDO tee /etc/default/zramswap >/dev/null \
        && $SUDO systemctl restart zramswap \
        && $SUDO systemctl enable zramswap
}

# _mem_make_swapfile ГБ [fstab-опции] [приоритет swapon] — создаёт /swapfile, включает и прописывает в fstab
_mem_make_swapfile() {
    local sz=$1 fstab_opts=${2:-sw} prio=${3:-}
    { $SUDO fallocate -l "${sz}G" /swapfile 2>/dev/null \
        || $SUDO dd if=/dev/zero of=/swapfile bs=1M count=$(( sz * 1024 )) status=none; } \
        && $SUDO chmod 600 /swapfile \
        && $SUDO mkswap /swapfile \
        && { { [ -n "$prio" ] && $SUDO swapon -p "$prio" /swapfile 2>/dev/null; } || $SUDO swapon /swapfile; } \
        && { grep -qE '^/swapfile\s' /etc/fstab \
            || echo "/swapfile none swap $fstab_opts 0 0" | $SUDO tee -a /etc/fstab >/dev/null; }
}

_mem_install_hybrid() {
    echo -e "$(tr_text L_MEMORY_023)"
    run_step "$(tr_text MEM_STEP_ZRAM)" _mem_setup_zram 50 || return 1
    if [ ! -f /swapfile ]; then
        echo -e "$(tr_text L_MEMORY_024)"
        run_step "$(tr_text MEM_STEP_SWAP)" _mem_make_swapfile 2 "sw,pri=-2" -2 || return 1
    fi
    echo -e "$(tr_text L_MEMORY_025)"
}

_mem_install_zram() {
    local pct=$1
    echo -e "$(tr_text L_MEMORY_026 "${pct}")"
    $SUDO swapoff -a 2>/dev/null || true
    $SUDO rm -f /swapfile 2>/dev/null
    $SUDO sed -i '/^\/swapfile/d' /etc/fstab 2>/dev/null
    run_step "$(tr_text MEM_STEP_ZRAM)" _mem_setup_zram "$pct" || return 1
    echo -e "$(tr_text L_MEMORY_027 "${pct}")"
}

_mem_install_swap() {
    local sz=$1
    echo -e "$(tr_text L_MEMORY_028 "${sz}")"
    $SUDO systemctl stop zramswap 2>/dev/null || true
    $SUDO apt-get remove --purge zram-tools -y >/dev/null 2>&1 || true
    $SUDO swapoff -a 2>/dev/null || true
    $SUDO rm -f /swapfile 2>/dev/null
    run_step "$(tr_text MEM_STEP_SWAP)" _mem_make_swapfile "$sz" sw || return 1
    echo -e "$(tr_text L_MEMORY_029 "${sz}")"
}

_mem_remove_all() {
    echo -e "$(tr_text L_MEMORY_030)"
    $SUDO systemctl stop zramswap 2>/dev/null || true
    $SUDO systemctl disable zramswap 2>/dev/null || true
    $SUDO apt-get remove --purge zram-tools -y >/dev/null 2>&1 || true
    $SUDO swapoff -a 2>/dev/null || true
    $SUDO rm -f /swapfile 2>/dev/null
    $SUDO sed -i '/^\/swapfile/d' /etc/fstab 2>/dev/null
    echo -e "$(tr_text L_MEMORY_031)"
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
        echo -e "$(tr_text L_MEMORY_032 "${rec_zram}" "${rec_swap}")"
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
