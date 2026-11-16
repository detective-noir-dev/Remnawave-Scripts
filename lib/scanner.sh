#!/bin/bash
# lib/scanner.sh — Сканер Reality (RealiTLScanner)
# Подключается из scripts.sh через load_modules; сам по себе не запускается.

SCANNER_DIR="/opt/RealityTLScanner"
SCANNER_BIN="$SCANNER_DIR/RealiTLScanner"
SCANNER_GEO="$SCANNER_DIR/Country.mmdb"
SCANNER_LIST="$SCANNER_DIR/targets.txt"

_scan_install() {
    export PATH=/usr/local/go/bin:$PATH
    # /opt принадлежит root: без прав создаём каталог через $SUDO и отдаём его текущему пользователю
    mkdir -p "$SCANNER_DIR/reports" 2>/dev/null \
        || { $SUDO mkdir -p "$SCANNER_DIR/reports" && $SUDO chown -R "$(id -u):$(id -g)" "$SCANNER_DIR"; } \
        || { echo -e "${RED}❌ Не удалось создать $SCANNER_DIR${NC}"; return 1; }

    if [ ! -f "$SCANNER_BIN" ]; then
        echo -e "${YELLOW}Устанавливаю RealiTLScanner (нужен Go для компиляции)...${NC}"
        _pkg_install git curl wget

        local go_arch="amd64"
        [ "$(uname -m)" = "aarch64" ] && go_arch="arm64"
        local go_ver
        go_ver=$(curl -4 -fsSL --connect-timeout 20 'https://go.dev/VERSION?m=text' 2>/dev/null | head -1)
        [[ "$go_ver" == go1.* ]] || go_ver="go1.22.6"
        echo -e "${BLUE}Загрузка Go ${go_ver} (${go_arch})...${NC}"
        curl -4 -sL --connect-timeout 120 \
            -o /tmp/go.tar.gz \
            "https://go.dev/dl/${go_ver}.linux-${go_arch}.tar.gz" || {
            echo -e "${RED}❌ Не удалось загрузить Go.${NC}"; return 1; }
        $SUDO rm -rf /usr/local/go
        $SUDO tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        export PATH=/usr/local/go/bin:$PATH

        local src="$SCANNER_DIR/src"
        rm -rf "$src"
        git clone https://github.com/xtls/RealiTLScanner.git "$src" || {
            echo -e "${RED}❌ Не удалось клонировать репозиторий.${NC}"; return 1; }
        echo -e "${CYAN}Компиляция...${NC}"
        cd "$src" || return 1
        go build -o "$SCANNER_BIN" && chmod +x "$SCANNER_BIN"
        rm -rf "$src"
        cd - >/dev/null || true
        [ -f "$SCANNER_BIN" ] \
            && echo -e "${GREEN}✅ RealiTLScanner установлен!${NC}" \
            || { echo -e "${RED}❌ Ошибка компиляции.${NC}"; return 1; }
    fi

    if [ ! -f "$SCANNER_GEO" ]; then
        echo -e "${BLUE}Загрузка GeoIP базы...${NC}"
        curl -sL --connect-timeout 30 \
            -o "$SCANNER_GEO" \
            "https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb" \
            || echo -e "${YELLOW}⚠️ Не удалось загрузить GeoIP базу.${NC}"
    fi
}

_scan_ensure() {
    if [ ! -f "$SCANNER_BIN" ]; then
        echo -e "${YELLOW}Сканер не установлен.${NC}"
        read -rp "Установить сейчас? (y/n): " ans
        [[ "$ans" =~ ^[YyДд]$ ]] || return 1
        _scan_install || return 1
    fi
    export PATH=/usr/local/go/bin:$PATH
    return 0
}

_scan_analyze() {
    local file=$1
    [ ! -f "$file" ] && return
    local lines; lines=$(wc -l < "$file" 2>/dev/null)
    [ "${lines:-0}" -le 1 ] && echo -e "${YELLOW}Результатов нет.${NC}" && return
    echo -e "${GREEN}🏆 ТОП-10 лучших SNI:${NC}"
    echo -e "${DIM}──────────────────────────────────────────${NC}"
    awk -F, 'NR>1{
        iss=tolower($4); w=9
        if(iss~/google|apple|microsoft/)       w=1
        else if(iss~/digicert|globalsign|sectigo/) w=2
        else if(iss~/cloudflare/)              w=3
        else if(iss~/lets encrypt|zerossl/)    w=4
        if(w<9){ port=($6?$6:"443"); print w"|"$3"|"$1"|"port"|"$5"|"$4 }
    }' "$file" | sort -t'|' -k1,1n | uniq | head -10 | \
    while IFS='|' read -r w dom ip port geo iss; do
        case $w in
            1) echo -e "  💎 ${CYAN}${BOLD}${dom}${NC}" ;;
            2|3) echo -e "  📍 ${GREEN}${dom}${NC}" ;;
            *) echo -e "  🔸 ${dom}" ;;
        esac
        echo -e "     ${DIM}IP: ${ip}  Порт: ${YELLOW}${port}${NC}${DIM}  ГЕО: ${geo}  ${iss}${NC}"
    done
}

_scan_single() {
    _scan_ensure || return
    show_banner
    print_submenu_header "$(tr_text SCAN_SINGLE)"
    echo -e "  ${CYAN}Проверяет конкретный IP/домен на пригодность для Reality-маскировки.${NC}"
    echo
    read -rp "$(tr_text SCAN_TARGET) " target
    [ -z "$target" ] && return
    read -rp "$(tr_text SCAN_PORT) " ports; ports=${ports:-443}

    local scan_target="$target"
    [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && scan_target="${target}/32"

    local ts; ts=$(date +%s)
    local out="$SCANNER_DIR/reports/scan_${ts}.csv"
    echo "ip,feasible,cert-domain,cert-issuer,geo,port" > "$out"
    cd "$SCANNER_DIR" || return

    IFS=',' read -ra _PORT_ARR <<< "${ports// /}"
    trap 'echo -e "\n${YELLOW}Прерывание...${NC}"' INT
    for port in "${_PORT_ARR[@]}"; do
        echo -e "${BLUE}──── Порт ${port} ────${NC}"
        local tmp="$SCANNER_DIR/.tmp_${ts}.csv"
        local log
        log=$("$SCANNER_BIN" -addr "$scan_target" -port "$port" -timeout 5 -v -out "$tmp" 2>&1)
        rm -f "$tmp"
        local found=false
        while IFS= read -r line; do
            if [[ "$line" == *"Connected to target"* ]]; then
                found=true
                local feas ip tls alpn dom iss geo
                feas=$(echo "$line" | grep -oP 'feasible=\K[^ ]+')
                ip=$(echo   "$line" | grep -oP 'ip=\K[^ ]+')
                tls=$(echo  "$line" | grep -oP 'tls=\K[^ "]+' | head -1)
                alpn=$(echo "$line" | grep -oP 'alpn=\K[^ "]+' | head -1)
                dom=$(echo  "$line" | grep -oP 'cert-domain=\K[^ "]+' | head -1)
                iss=$(echo  "$line" | grep -oP 'cert-issuer=\K[^ "]+' | head -1)
                geo=$(echo  "$line" | grep -oP 'geo=\K[^ ]+')
                echo
                echo -e "  🌐 IP:       ${ip:-?}"
                [ "$feas" = "true" ] \
                    && echo -e "  ${GREEN}✅ ПОДХОДИТ ДЛЯ REALITY${NC}" \
                    || echo -e "  ${RED}❌ НЕ ПОДХОДИТ${NC}"
                echo -e "  🔒 TLS:      ${tls:-?}    ⚡ ALPN: ${alpn:-?}"
                echo -e "  📍 Домен:    ${dom:-?}"
                echo -e "  🏢 Издатель: ${iss:-?}    🌍 ГЕО: ${geo:-?}"
                echo
                echo "${ip},${feas},${dom},${iss},${geo},${port}" >> "$out"
            elif [[ "$line" == *"TLS handshake failed"* || "$line" == *"Cannot dial"* ]]; then
                found=true
                echo -e "  ${RED}❌ Соединение не установлено (TLS/connect error).${NC}"
            fi
        done <<< "$log"
        $found || echo -e "  ${YELLOW}⚠️ Нет ответа от ${target}:${port}${NC}"
    done
    trap - INT
    cd - >/dev/null || true

    local cnt; cnt=$(( $(wc -l < "$out" 2>/dev/null) - 1 ))
    [ "$cnt" -gt 0 ] && echo && _scan_analyze "$out"
    echo
    echo -e "${DIM}Отчёт: $out${NC}"
    read -rp "$(tr_text PRESS_ENTER)"
}

_scan_mass() {
    _scan_ensure || return
    touch "$SCANNER_LIST"
    if [ ! -s "$SCANNER_LIST" ]; then
        show_banner
        print_submenu_header "$(tr_text SCAN_MASS)"
        echo -e "  ${YELLOW}Файл списка пуст: $SCANNER_LIST${NC}"
        echo -e "  ${DIM}Добавьте цели через меню «Список целей».${NC}"
        echo
        read -rp "$(tr_text PRESS_ENTER)"; return
    fi
    show_banner
    print_submenu_header "$(tr_text SCAN_MASS)"
    local total; total=$(grep -c '.' "$SCANNER_LIST" 2>/dev/null || echo 0)
    echo -e "  ${CYAN}Целей в списке: ${YELLOW}$total${NC}"
    echo
    read -rp "$(tr_text SCAN_PORT) " ports; ports=${ports:-443}

    local ts; ts=$(date +%s)
    local out="$SCANNER_DIR/reports/mass_${ts}.csv"
    echo "ip,feasible,cert-domain,cert-issuer,geo,port" > "$out"
    cd "$SCANNER_DIR" || return

    IFS=',' read -ra _PORT_ARR <<< "${ports// /}"
    local done_cnt=0
    trap 'echo -e "\n${YELLOW}Прерывание — сохраняем...${NC}"; break' INT
    while IFS= read -r raw; do
        [ -z "$raw" ] && continue
        local t="$raw"
        [[ "$t" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && t="${t}/32"
        ((done_cnt++))
        echo -ne "\r\033[K${CYAN}[$done_cnt/$total]${NC} ${YELLOW}${raw}${NC}..."
        for port in "${_PORT_ARR[@]}"; do
            local tmp="$SCANNER_DIR/.tmp_${ts}.csv"
            local log
            log=$("$SCANNER_BIN" -addr "$t" -port "$port" -timeout 5 -v -out "$tmp" 2>&1)
            rm -f "$tmp"
            while IFS= read -r line; do
                if [[ "$line" == *"Connected to target"* ]]; then
                    local feas ip dom iss geo
                    feas=$(echo "$line" | grep -oP 'feasible=\K[^ ]+')
                    ip=$(echo   "$line" | grep -oP 'ip=\K[^ ]+')
                    dom=$(echo  "$line" | grep -oP 'cert-domain=\K[^ "]+' | head -1)
                    iss=$(echo  "$line" | grep -oP 'cert-issuer=\K[^ "]+' | head -1)
                    geo=$(echo  "$line" | grep -oP 'geo=\K[^ ]+')
                    echo "${ip},${feas},${dom},${iss},${geo},${port}" >> "$out"
                fi
            done <<< "$log"
        done
    done < "$SCANNER_LIST"
    trap - INT

    echo -e "\r\033[K${GREEN}✅ Готово! (${done_cnt} целей просканировано)${NC}"
    cd - >/dev/null || true
    echo
    _scan_analyze "$out"
    echo
    echo -e "${DIM}Отчёт: $out${NC}"
    read -rp "$(tr_text PRESS_ENTER)"
}

_scan_manage_list() {
    while true; do
        show_banner
        print_submenu_header "📋 Список целей"
        touch "$SCANNER_LIST"
        local cnt; cnt=$(grep -c '.' "$SCANNER_LIST" 2>/dev/null || echo 0)
        echo -e "  ${DIM}$SCANNER_LIST (${cnt} целей)${NC}"
        echo
        if [ "$cnt" -gt 0 ]; then
            grep -n '.' "$SCANNER_LIST" 2>/dev/null | head -20 | \
                while IFS=: read -r n line; do echo -e "  ${DIM}$n)${NC} $line"; done
            [ "$cnt" -gt 20 ] && echo -e "  ${DIM}... и ещё $(( cnt - 20 )) записей${NC}"
            echo
        fi
        echo -e "  ${YELLOW}1)${NC} ➕ Добавить цель (IP или домен)"
        echo -e "  ${YELLOW}2)${NC} 🗑️  Очистить весь список"
        echo -e "  ${YELLOW}3)${NC} ✏️  Открыть в nano"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        case $choice in
            1) read -rp "IP или домен: " t
               [ -n "$t" ] && echo "$t" >> "$SCANNER_LIST" \
               && echo -e "${GREEN}✅ Добавлено: $t${NC}" && sleep 1 ;;
            2) : > "$SCANNER_LIST"; echo -e "${GREEN}✅ Список очищен.${NC}"; sleep 1 ;;
            3) command -v nano >/dev/null 2>&1 && nano "$SCANNER_LIST" \
               || { echo -e "${RED}nano не установлен.${NC}"; sleep 1; } ;;
            0) return ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}

_scan_reports() {
    while true; do
        show_banner
        print_submenu_header "📂 Отчёты сканера"
        local rdir="$SCANNER_DIR/reports"
        mkdir -p "$rdir"
        local i=1
        declare -a _rfiles=()
        while IFS= read -r f; do
            local base; base=$(basename "$f")
            local sz; sz=$(du -sh "$f" | awk '{print $1}')
            local rlines; rlines=$(wc -l < "$f" 2>/dev/null)
            echo -e "  ${YELLOW}$i)${NC} ${base} ${DIM}(${sz}, ${rlines} строк)${NC}"
            _rfiles[$i]="$f"; ((i++))
        done < <(ls -t "$rdir"/*.csv 2>/dev/null)
        [ ${#_rfiles[@]} -eq 0 ] && echo -e "  ${YELLOW}Отчётов нет.${NC}"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "Номер для анализа (0 = назад): " sel
        [ "$sel" = "0" ] || [ -z "$sel" ] && return
        if [[ "$sel" =~ ^[0-9]+$ ]] && [ -n "${_rfiles[$sel]:-}" ]; then
            show_banner
            print_submenu_header "📊 $(basename "${_rfiles[$sel]}")"
            _scan_analyze "${_rfiles[$sel]}"
            echo
            read -rp "$(tr_text PRESS_ENTER)"
        fi
    done
}

submenu_scanner() {
    while true; do
        show_banner
        print_submenu_header "$(tr_text GROUP_SCANNER)"
        echo -e "  ${DIM}Поиск идеальных SNI-доменов для маскировки Reality/VLESS.${NC}"
        local _sc_status
        [ -f "$SCANNER_BIN" ] \
            && _sc_status="${GREEN}✅ Установлен${NC}" \
            || _sc_status="${RED}❌ Не установлен${NC}"
        echo -e "  ${DIM}Статус сканера: $_sc_status${NC}"
        echo
        echo -e "  ${YELLOW}1)${NC} $(tr_text SCAN_SINGLE)"
        echo -e "  ${YELLOW}2)${NC} $(tr_text SCAN_MASS)"
        echo -e "  ${YELLOW}3)${NC} 📋 Список целей"
        echo -e "  ${YELLOW}4)${NC} 📂 Отчёты"
        echo -e "  ${DIM}──────────────────────────────${NC}"
        echo -e "  ${YELLOW}5)${NC} 🔧 Установить / переустановить сканер"
        echo
        echo -e "  ${DIM}${YELLOW}0)${NC} $(tr_text MENU_BACK)"
        echo
        read -rp "> " choice
        case $choice in
            1) _scan_single ;;
            2) _scan_mass ;;
            3) _scan_manage_list ;;
            4) _scan_reports ;;
            5) show_banner; _scan_install; read -rp "$(tr_text PRESS_ENTER)" ;;
            0) break ;;
            *) echo -e "${RED}$(tr_text ERR_CHOICE)${NC}"; sleep 1 ;;
        esac
    done
}
