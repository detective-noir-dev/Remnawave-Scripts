#!/bin/bash

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="rw-scripts"
REPO_URL="https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main"
CONFIG_DIR="$HOME/.config/remnawave"
LANG_FILE="$CONFIG_DIR/lang.conf"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/remnawave"

mkdir -p "$CONFIG_DIR" "$INSTALL_DIR" "$DATA_DIR"

# === ПОДТЯГИВАЕМ АКТУАЛЬНУЮ ВЕРСИЮ ###
if curl -fsSL -o "$DATA_DIR/version.txt.new" "$REPO_URL/version.txt"; then
    NEW_VERSION=$(tr -d '\r\n' < "$DATA_DIR/version.txt.new")
else
    NEW_VERSION="dev"
fi

# === ЧИТАЕМ ТЕКУЩУЮ ВЕРСИЮ ЕСЛИ УСТАНОВЛЕНА ===
CURRENT_VERSION="(not installed)"
if [ -f "$DATA_DIR/version.txt" ]; then
    CURRENT_VERSION=$(tr -d '\r\n' < "$DATA_DIR/version.txt")
fi

clear
echo -e "\e[36m🚀 Remnawave Scripts Installer/Updater\e[0m"
echo "----------------------------------------------"
if [ "$CURRENT_VERSION" = "(not installed)" ]; then
    echo -e "📦 Fresh install → Version: \e[33m$NEW_VERSION\e[0m"
else
    echo -e "🔄 Update: $CURRENT_VERSION → \e[32m$NEW_VERSION\e[0m"
fi
echo "----------------------------------------------"

# === ВЫБОР ЯЗЫКА ===
if [ ! -f "$LANG_FILE" ]; then
    echo -e "\nChoose installation language / Выберите язык установки:"
    echo "1) English"
    echo "2) Русский"
    printf "Enter number (1/2): "
    read -r lang_choice

    case "$lang_choice" in
        1) echo "en" > "$LANG_FILE"; LANG_NAME="English" ;;
        2) echo "ru" > "$LANG_FILE"; LANG_NAME="Русский" ;;
        *) echo "en" > "$LANG_FILE"; LANG_NAME="English (default)" ;;
    esac
    echo -e "\e[32mLanguage set to: $LANG_NAME\e[0m"
fi

# === СКАЧИВАНИЕ ОСНОВНЫХ ФАЙЛОВ ===

# rw-scripts binary
if ! curl -fsSL -o "$INSTALL_DIR/$SCRIPT_NAME" "$REPO_URL/scripts.sh"; then
    echo -e "\e[31m❌ Failed to download main script (scripts.sh)\e[0m"
    exit 1
fi
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# uninstall.sh
if ! curl -fsSL -o "$DATA_DIR/uninstall.sh" "$REPO_URL/uninstall.sh"; then
    echo -e "\e[31m❌ Failed to download uninstall.sh\e[0m"
    exit 1
fi
chmod +x "$DATA_DIR/uninstall.sh"

# version.txt (обновляем "боевой" файл)
mv "$DATA_DIR/version.txt.new" "$DATA_DIR/version.txt"

# countries.csv
if ! curl -fsSL -o "$DATA_DIR/countries.csv" "$REPO_URL/countries.csv"; then
    echo -e "\e[31m❌ Failed to download countries.csv\e[0m"
    exit 1
fi

# === PATH CONFIG ===
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    if ! grep -Fxq "export PATH=\$PATH:$INSTALL_DIR" "$HOME/.bashrc"; then
        echo "export PATH=\$PATH:$INSTALL_DIR" >> "$HOME/.bashrc"
        echo -e "\e[33m[!] Added $INSTALL_DIR to PATH (restart terminal or run 'source ~/.bashrc').\e[0m"
    fi
fi

# === ЗАВЕРШЕНИЕ ===
LANG_SET=$(cat "$LANG_FILE")
echo
if [[ "$LANG_SET" == "ru" ]]; then
    if [ "$CURRENT_VERSION" = "(not installed)" ]; then
        echo -e "\e[32m✅ Установка завершена!\e[0m"
    else
        echo -e "\e[32m✅ Обновление завершено!\e[0m"
    fi
    echo "Версия: $NEW_VERSION"
    echo "Бинарь: $INSTALL_DIR/$SCRIPT_NAME"
    echo "Данные: $DATA_DIR"
    echo "Конфиг: $CONFIG_DIR"
    echo "Запускайте: $SCRIPT_NAME"
else
    if [ "$CURRENT_VERSION" = "(not installed)" ]; then
        echo -e "\e[32m✅ Installation completed!\e[0m"
    else
        echo -e "\e[32m✅ Update completed!\e[0m"
    fi
    echo "Version: $NEW_VERSION"
    echo "Binary: $INSTALL_DIR/$SCRIPT_NAME"
    echo "Data dir: $DATA_DIR"
    echo "Config dir: $CONFIG_DIR"
    echo "Run with: $SCRIPT_NAME"
fi