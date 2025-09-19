#!/bin/bash
# Версия
VERSION="0.0.5"

# Цвета
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'
NC='\e[0m'

# ====== ФУНКЦИЯ СПИННЕРА ======
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local start_time=$(date +%s)
    local min_duration=3
    echo -ne "${YELLOW}"
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    if [ $elapsed -lt $min_duration ]; then
        sleep $((min_duration - elapsed))
    fi
    echo -ne "${NC}"
}

# ====== ГЕНЕРАЦИЯ SHORTS_ID ======
generate_ids() {
    echo "Сколько идентификаторов сгенерировать?"
    read count
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Ошибка: введите корректное число!${NC}"
        return
    fi
    if [ "$count" -le 0 ]; then
        echo -e "${RED}Ошибка: количество должно быть больше нуля!${NC}"
        return
    fi

    {
        for ((i=1; i<=count; i++)); do
            id=$(head -c 8 /dev/urandom | xxd -p)
            echo "\"$id\","
        done
    } > /tmp/ids_output.txt &

    pid=$!
    spinner $pid
    wait $pid
    status=$?

    echo
    if [ $status -ne 0 ]; then
        echo -e "${RED}Произошла ошибка во время генерации.${NC}"
        return
    fi

    echo -e "${GREEN}ID сгенерированы! Вот твой список:${NC}\n"
    cat /tmp/ids_output.txt
    echo -e "\a"
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
    while true; do
        echo "Введите название страны (на русском или английском, можно часть, 0 = выход в меню):"
        read input

        if [[ "$input" == "0" ]]; then
            return
        fi

        key=$(echo "$input" | tr '[:upper:]' '[:lower:]')
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

        matches=$(awk -F',' -v key="$key" -v file="$SCRIPT_DIR/countries.csv" '
        BEGIN {
            i=0;
            while ((getline < file) > 0) {
                ru=tolower($1); en=tolower($2); iso=$3;
                gsub(/\r$/,"",ru); gsub(/\r$/,"",en);
                if (ru ~ key || en ~ key) {
                    i++;
                    result[i]=iso "," en;
                }
            }
            for (j=1; j<=i; j++) print result[j];
        }')

        if [ -z "$matches" ]; then
            echo -e "${RED}Ничего не найдено по запросу '${input}'.${NC}"
            continue
        fi

        total=$(echo "$matches" | wc -l)
        echo -e "${GREEN}Результаты поиска:${NC}"
        i=1
        echo "$matches" | while IFS=',' read -r iso en; do
            flag=$(iso_to_flag "$iso")
            echo " $i) $flag $en"
            i=$((i+1))
        done > /tmp/matches_list.txt

        cat /tmp/matches_list.txt

        echo "Выберите номер (или 0 для нового поиска):"
        read choice

        if [[ "$choice" == "0" ]]; then
            continue
        fi

        if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Введите корректный номер!${NC}"
            continue
        fi

        selected=$(sed -n "${choice}p" /tmp/matches_list.txt | awk '{print $2,$3,$4}')
        if [ -z "$selected" ]; then
            echo -e "${RED}Нет варианта с таким номером.${NC}"
            continue
        fi

        echo -e "${YELLOW}Вы выбрали:${NC} $selected"
        return
    done
}

# ====== ПРОВЕРКА ОБНОВЛЕНИЙ ======
check_update() {
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    latest=$(curl -s https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main/version.txt)

    if [ -z "$latest" ]; then
        echo -e "${RED}Не удалось проверить обновления.${NC}"
        return
    fi

    echo "Текущая версия: $VERSION"
    echo "Последняя версия: $latest"

    if [ "$VERSION" != "$latest" ]; then
        echo -e "${YELLOW}Есть новая версия! Хотите обновиться? (y/n)${NC}"
        read ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            curl -o "$SCRIPT_DIR/scripts.sh" https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main/scripts.sh
            chmod +x "$SCRIPT_DIR/scripts.sh"
            echo -e "${GREEN}Скрипт обновлён до версии $latest${NC}"
        fi
    else
        echo -e "${GREEN}У вас уже последняя версия.${NC}"
    fi
}

# ====== МЕНЮ ======
show_menu() {
    echo "Выберите действие:"
    echo "1) Сгенерировать shorts_id"
    echo "2) Узнать флаг страны"
    echo "3) Проверить версию/обновить"
    echo "0) Выйти"
    read choice
    case $choice in
        1) generate_ids ;;
        2) country_lookup ;;
        3) check_update ;;
        0) echo "Выход... Пока 👋"; exit 0 ;;
        *) echo -e "${RED}Неверный выбор, попробуй ещё раз 😅${NC}" ;;
    esac
}

while true; do
    show_menu
done