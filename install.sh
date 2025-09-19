#!/bin/bash

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="rw-scripts"
REPO_URL="https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main"
CONFIG_DIR="$HOME/.config/remnawave"
LANG_FILE="$CONFIG_DIR/lang.conf"

# === ПОДТЯГИВАЕМ АКТУАЛЬНУЮ ВЕРСИЮ С ГИТХАБА ===
VERSION=$(curl -s "$REPO_URL/version.txt")
if [ -z "$VERSION" ]; then
    VERSION="dev"  # fallback если нет сети
fi

echo -e "\e[36m🚀 Starting Remnawave Scripts installer v$VERSION...\e[0m"

# === ВЫБОР ЯЗЫКА ===
echo -e "\nChoose installation language / Выберите язык установки:"
echo "1) English"
echo "2) Русский"
printf "Enter number (1/2): "
read -r lang_choice

# создаём папку для конфигурации
mkdir -p "$CONFIG_DIR"

case "$lang_choice" in
    1) echo "en" > "$LANG_FILE"; LANG_NAME="English" ;;
    2) echo "ru" > "$LANG_FILE"; LANG_NAME="Русский" ;;
    *) echo "en" > "$LANG_FILE"; LANG_NAME="English (default)" ;;
esac

echo -e "\e[32mLanguage set to: $LANG_NAME\e[0m\n"

# создаём папку для конфигурации
mkdir -p "$CONFIG_DIR"

case "$lang_choice" in
    1) echo "en" > "$LANG_FILE"; LANG_NAME="English" ;;
    2) echo "ru" > "$LANG_FILE"; LANG_NAME="Русский" ;;
    *) echo "en" > "$LANG_FILE"; LANG_NAME="English (default)" ;;
esac

echo -e "\e[32mLanguage set to: $LANG_NAME\e[0m\n"

# === УСТАНОВКА ===
mkdir -p "$INSTALL_DIR"

# качаем основной скрипт
curl -s -o "$INSTALL_DIR/$SCRIPT_NAME" "$REPO_URL/scripts.sh"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# качаем uninstall.sh тоже!
curl -s -o "$INSTALL_DIR/uninstall.sh" "$REPO_URL/uninstall.sh"
chmod +x "$INSTALL_DIR/uninstall.sh"

# качаем версию
curl -s -o "$INSTALL_DIR/version.txt" "$REPO_URL/version.txt"

# качаем файл со странами
curl -s -o "$INSTALL_DIR/countries.csv" "$REPO_URL/countries.csv"

# проверим PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    if ! grep -Fxq "export PATH=\$PATH:$INSTALL_DIR" "$HOME/.bashrc"; then
        echo "export PATH=\$PATH:$INSTALL_DIR" >> "$HOME/.bashrc"
        echo -e "\e[33m[!] Added $INSTALL_DIR to PATH (restart terminal).\e[0m"
    fi
fi

# финальное сообщение в зависимости от языка
LANG_SET=$(cat "$LANG_FILE")
echo
if [[ "$LANG_SET" == "ru" ]]; then
    echo -e "\e[32m✅ Установка завершена!\e[0m"
    echo "Установлена версия: $VERSION"
    echo "Теперь можно запускать с помощью команды: $SCRIPT_NAME"
else
    echo -e "\e[32m✅ Installation completed!\e[0m"
    echo "Installed version: $VERSION"
    echo "You can now run it with: $SCRIPT_NAME"
fi