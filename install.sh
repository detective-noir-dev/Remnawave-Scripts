#!/bin/bash

VERSION="0.0.4"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="rw-scripts"
REPO_URL="https://raw.githubusercontent.com/detectivenoirr/Remnawave-Scripts/main"

echo -e "\e[36m🚀 Установка RW Scripts версии $VERSION...\e[0m"

mkdir -p "$INSTALL_DIR"

# копируем актуальный скрипт
curl -s -o "$INSTALL_DIR/$SCRIPT_NAME" "$REPO_URL/scripts.sh"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# кладём файл версии
echo "$VERSION" > "$INSTALL_DIR/version.txt"

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    if ! grep -Fxq "export PATH=\$PATH:$INSTALL_DIR" "$HOME/.bashrc"; then
        echo "export PATH=\$PATH:$INSTALL_DIR" >> "$HOME/.bashrc"
        echo -e "\e[33m[!] Папка $INSTALL_DIR добавлена в PATH (перезапусти терминал).\e[0m"
    fi
fi

echo -e "\n\e[32m✅ Установка завершена!\e[0m"
echo "Теперь можно запускать с помощью команды: $SCRIPT_NAME"