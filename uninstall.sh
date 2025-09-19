#!/bin/bash

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="rw-scripts"

echo -e "\e[33m⚠️ Вы уверены, что хотите удалить $SCRIPT_NAME (y/n)?\e[0m"
read confirm

if [[ "$confirm" =~ ^[YyДд]$ ]]; then
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        rm -f "$INSTALL_DIR/$SCRIPT_NAME"
        echo -e "\e[31mУдалён $INSTALL_DIR/$SCRIPT_NAME\e[0m"
    else
        echo -e "\e[36mФайл $INSTALL_DIR/$SCRIPT_NAME не найден (может быть уже удалён).\e[0m"
    fi

    if [ -f "$INSTALL_DIR/version.txt" ]; then
        rm -f "$INSTALL_DIR/version.txt"
        echo -e "\e[31mУдалён $INSTALL_DIR/version.txt\e[0m"
    fi

    echo -e "\e[32m✅ Удаление завершено!\e[0m"
else
    echo -e "\e[32mОтмена удаления.\e[0m"
fi