#!/bin/bash
# lib/system.sh — Системная информация, память, htop, подменю мониторинга
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

# ====== ФУНКЦИЯ: СИСТЕМНАЯ ИНФА ======
show_system_info() {
    echo -e "${GREEN}======== 📊 System Information ========${NC}"

    if ! command -v neofetch >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Neofetch is not installed.${NC}"
        read -rp "👉 Install neofetch now? (y/n): " ans
        if [[ "$ans" =~ ^[YyДд]$ ]]; then
            echo -e "${BLUE}🔧 Installing neofetch...${NC}"
            loading_bar & pid=$!
            if ! pkg_mgr >/dev/null; then
                kill $pid >/dev/null 2>&1; tput cnorm
                echo -e "\r${RED}❌ Could not detect a package manager. Please install neofetch manually.${NC}          "
                return 1
            fi
            pkg_install neofetch &>/dev/null
            kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm
            echo -e "\r✅ Neofetch installed!                                                              "
        else
            echo -e "${RED}❌ Neofetch not installed. Skipping system info.${NC}"
            return 0
        fi
    fi

    if command -v neofetch >/dev/null 2>&1; then
        neofetch
    else
        echo -e "${RED}❌ Neofetch installation failed.${NC}"
    fi

    echo -e "${GREEN}========================================${NC}"
}

# ====== ПОКАЗАТЬ СВОБОДНУЮ ПАМЯТЬ ======
show_memory() {
    echo -e "${GREEN}======== 💾 Memory Information ========${NC}"
    
    if command -v free >/dev/null 2>&1; then
        free -h
    else
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "${BLUE}Memory stats (macOS):${NC}"
            vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("%-16s % 16.2f MB\n", "$1:", $2 * $size / 1048576);'
        else
            echo -e "${YELLOW}⚠️  'free' command not found. Trying alternative...${NC}"
            if [ -f /proc/meminfo ]; then
                awk '/MemTotal|MemFree|MemAvailable|Buffers|Cached/ {printf "%-20s: %10s kB\n", $1, $2}' /proc/meminfo
            else
                echo -e "${RED}❌ Cannot determine memory information on this system.${NC}"
            fi
        fi
    fi
    
    echo -e "${GREEN}========================================${NC}"
}

# ====== ЗАПУСК HTOP ======
launch_htop() {
    if ! command -v htop >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  htop is not installed.${NC}"
        read -rp "👉 Install htop now? (y/n): " ans
        if [[ "$ans" =~ ^[YyДд]$ ]]; then
            echo -e "${BLUE}🔧 Installing htop...${NC}"
            loading_bar & pid=$!
            
            if ! pkg_mgr >/dev/null; then
                kill $pid >/dev/null 2>&1; tput cnorm
                echo -e "\r${RED}❌ Could not detect a package manager. Please install htop manually.${NC}          "
                return 1
            fi
            pkg_install htop &>/dev/null
            
            kill $pid >/dev/null 2>&1; wait $pid 2>/dev/null; tput cnorm
            echo -e "\r✅ htop installed!                                                              "
        else
            echo -e "${RED}❌ htop not installed. Returning to menu.${NC}"
            return 0
        fi
    fi

    if command -v htop >/dev/null 2>&1; then
        echo -e "${GREEN}🚀 Launching htop... (Press 'q' or F10 to exit)${NC}"
        sleep 1
        htop
    else
        echo -e "${RED}❌ htop installation failed.${NC}"
    fi
}

# ====== ПОДМЕНЮ 2: Resource Monitor ======
submenu_monitor() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_MONITOR)"
        
        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_MEMORY)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_HTOP)"
        echo -e "  ${YELLOW}3)${NC} $(tr_text SUB_SYSINFO)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        
        case $choice in
            1) show_banner; show_memory; echo; read -rp "$(tr_text PRESS_ENTER)" ;;
            2) show_banner; launch_htop ;;
            3) show_banner; show_system_info; echo; read -rp "$(tr_text PRESS_ENTER)" ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}
