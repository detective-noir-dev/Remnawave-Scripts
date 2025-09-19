#!/bin/bash

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="rw-scripts"
CONFIG_DIR="$HOME/.config/remnawave"
LANG_FILE="$CONFIG_DIR/lang.conf"

# Цвета (для красоты)
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'
CYAN='\e[36m'
NC='\e[0m'

# Загружаем язык
if [ -f "$LANG_FILE" ]; then
    LANG_SET=$(cat "$LANG_FILE")
else
    LANG_SET="en" # fallback
fi

# Словарь переводов
tr_text() {
    case "$LANG_SET" in
        "ru")
            case "$1" in
                CONFIRM)   echo "⚠️ Вы уверены, что хотите удалить $SCRIPT_NAME (y/n)?" ;;
                FILE_DEL)  echo "Удалён" ;;
                FILE_MISS) echo "Файл не найден (может быть уже удалён)." ;;
                DONE)      echo "✅ Удаление завершено!" ;;
                CANCEL)    echo "Отмена удаления." ;;
            esac
            ;;
        "en" | *)
            case "$1" in
                CONFIRM)   echo "⚠️ Are you sure you want to uninstall $SCRIPT_NAME (y/n)?" ;;
                FILE_DEL)  echo "Removed" ;;
                FILE_MISS) echo "File not found (maybe already deleted)." ;;
                DONE)      echo "✅ Uninstall complete!" ;;
                CANCEL)    echo "Uninstall canceled." ;;
            esac
            ;;
    esac
}

# ==== Основная логика удаления ====
echo -e "${YELLOW}$(tr_text CONFIRM)${NC}"
read confirm

if [[ "$confirm" =~ ^[YyДд]$ ]]; then
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        rm -f "$INSTALL_DIR/$SCRIPT_NAME"
        echo -e "${RED}$(tr_text FILE_DEL): $INSTALL_DIR/$SCRIPT_NAME${NC}"
    else
        echo -e "${CYAN}$INSTALL_DIR/$SCRIPT_NAME — $(tr_text FILE_MISS)${NC}"
    fi

    if [ -f "$INSTALL_DIR/version.txt" ]; then
        rm -f "$INSTALL_DIR/version.txt"
        echo -e "${RED}$(tr_text FILE_DEL): $INSTALL_DIR/version.txt${NC}"
    fi

    echo -e "${GREEN}$(tr_text DONE)${NC}"
else
    echo -e "${GREEN}$(tr_text CANCEL)${NC}"
fi