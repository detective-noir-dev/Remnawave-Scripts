#!/bin/bash
# lib/ids.sh — Short ID, флаги стран, поиск по countries.csv
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

# ====== ГЕНЕРАЦИЯ ID ======
ensure_xxd() {
    if command -v xxd >/dev/null 2>&1; then return 0; fi
    echo -e "${YELLOW}⚙️  Устанавливаю 'xxd'...${NC}"

    pkg_install_any vim-xxd xxd >/dev/null 2>&1 || {
        echo -e "${RED}❌ Не удалось установить xxd.${NC}"
        return 1
    }

    command -v xxd >/dev/null 2>&1 && echo -e "${GREEN}✅ xxd установлен!${NC}" || return 1
}

generate_ids() {
    ensure_xxd || return
    echo -ne "${BLUE}$(tr_text IDS_HOW_MANY)${NC} "
    read -r count
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}$(tr_text ERR_NUMBER)${NC}"; return
    fi
    if [ "$count" -le 0 ]; then
        echo -e "${RED}$(tr_text ERR_GT_ZERO)${NC}"; return
    fi
    echo -e "${GREEN}$(tr_text IDS_DONE)${NC}\n"
    for ((i=1; i<=count; i++)); do
        id=$(head -c 8 /dev/urandom | xxd -p)
        echo "\"$id\","
    done
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== ISO→ФЛАГ ======
iso_to_flag() {
    country_code=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    for ((i=0; i<${#country_code}; i++)); do
        char=${country_code:i:1}
        code=$(( $(printf '%d' "'$char") - 65 + 0x1F1E6 ))
        printf "\\U$(printf '%X' $code)"
    done
}

# ====== ПОИСК СТРАН ======
country_lookup() {
    echo "$(tr_text COUNTRY_PROMPT)"
    read input
    [ "$input" = "0" ] && return
    key=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    COUNTRIES_FILE="$DATA_DIR/countries.csv"
    if [ ! -f "$COUNTRIES_FILE" ]; then
        echo -e "${RED}countries.csv not found${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return
    fi
    matches=$(awk -F',' -v key="$key" '
    { ru=tolower($1); en=tolower($2); iso=$3;
      if (ru ~ key || en ~ key) { print iso "," $2; }
    }' "$COUNTRIES_FILE")
    if [ -z "$matches" ]; then
        echo -e "${RED}$(tr_text NOTHING_FOUND) '${input}'.${NC}"
        read -rp "$(tr_text PRESS_ENTER)"
        return
    fi
    total=$(echo "$matches" | wc -l)
    if [ "$total" -gt 10 ]; then
        echo -e "${YELLOW}Найдено ${total}. Показать все? (y/n)${NC}"
        read ans
        [[ ! "$ans" =~ ^[YyДд]$ ]] && return
    fi
    echo -e "${GREEN}$(tr_text RESULTS)${NC}"
    echo "$matches" | while IFS=',' read -r iso en; do
        flag=$(iso_to_flag "$iso")
        echo " $flag $en"
    done
    echo
    read -rp "$(tr_text PRESS_ENTER)"
}

# ====== ПОДМЕНЮ 1: Short ID & Flags ======
submenu_id_flags() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_ID_FLAGS)"
        
        echo -e "  ${YELLOW}1)${NC} $(tr_text SUB_GEN_IDS)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SUB_FLAG)"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        
        case $choice in
            1) show_banner; generate_ids ;;
            2) show_banner; country_lookup ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}
