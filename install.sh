#!/bin/bash

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="rw-scripts"
REPO_URL="https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main"
CONFIG_DIR="$HOME/.config/remnawave"
LANG_FILE="$CONFIG_DIR/lang.conf"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/remnawave"

mkdir -p "$CONFIG_DIR" "$INSTALL_DIR" "$DATA_DIR"

# === ПРОВЕРКА И УСТАНОВКА SUDO ===
check_and_install_sudo() {
    if ! command -v sudo >/dev/null 2>&1; then
        echo -e "\e[33m⚠️  'sudo' не найден в системе. Устанавливаю...\e[0m"
        
        # Проверяем, запущен ли скрипт от root
        if [ "$EUID" -ne 0 ]; then
            echo -e "\e[31m❌ Для установки sudo требуются права root.\e[0m"
            echo -e "\e[33m💡 Запустите скрипт от root или установите sudo вручную:\e[0m"
            
            if command -v apt-get >/dev/null 2>&1; then
                echo "   su -c 'apt-get update && apt-get install -y sudo'"
            elif command -v dnf >/dev/null 2>&1; then
                echo "   su -c 'dnf install -y sudo'"
            elif command -v yum >/dev/null 2>&1; then
                echo "   su -c 'yum install -y sudo'"
            elif command -v pacman >/dev/null 2>&1; then
                echo "   su -c 'pacman -Sy --noconfirm sudo'"
            elif command -v zypper >/dev/null 2>&1; then
                echo "   su -c 'zypper install -y sudo'"
            fi
            
            read -rp "Продолжить установку без sudo? (y/n): " choice
            if [[ ! "$choice" =~ ^[YyДд]$ ]]; then
                echo -e "\e[31m❌ Установка отменена.\e[0m"
                exit 1
            fi
            return 1
        fi
        
        # Устанавливаем sudo (от root)
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update -qq && apt-get install -y sudo
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y sudo
        elif command -v yum >/dev/null 2>&1; then
            yum install -y sudo
        elif command -v pacman >/dev/null 2>&1; then
            pacman -Sy --noconfirm sudo
        elif command -v zypper >/dev/null 2>&1; then
            zypper install -y sudo
        elif command -v apk >/dev/null 2>&1; then
            apk add sudo
        else
            echo -e "\e[31m❌ Не удалось определить пакетный менеджер.\e[0m"
            return 1
        fi
        
        if command -v sudo >/dev/null 2>&1; then
            echo -e "\e[32m✅ sudo успешно установлен!\e[0m"
        else
            echo -e "\e[31m❌ Не удалось установить sudo.\e[0m"
            return 1
        fi
    fi
    return 0
}

# Проверяем sudo перед началом установки
check_and_install_sudo

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
PATH_ADDED=0
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    # Определяем какой shell используется
    if [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    else
        # Пробуем определить по переменной SHELL
        case "$SHELL" in
            */zsh)
                SHELL_RC="$HOME/.zshrc"
                ;;
            */bash)
                SHELL_RC="$HOME/.bashrc"
                ;;
            *)
                SHELL_RC="$HOME/.profile"
                ;;
        esac
    fi
    
    # Добавляем PATH в конфиг если его там нет
    if ! grep -Fxq "export PATH=\$PATH:$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
        echo "export PATH=\$PATH:$INSTALL_DIR" >> "$SHELL_RC"
        PATH_ADDED=1
    fi
    
    # Применяем PATH для текущей сессии
    export PATH="$PATH:$INSTALL_DIR"
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
    echo ""
    if [ "$PATH_ADDED" -eq 1 ]; then
        echo -e "\e[33m[i] PATH обновлен автоматически. Можете сразу использовать команду.\e[0m"
    fi
    echo -e "\e[32mЗапускайте прямо сейчас: $SCRIPT_NAME\e[0m"
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
    echo ""
    if [ "$PATH_ADDED" -eq 1 ]; then
        echo -e "\e[33m[i] PATH updated automatically. You can use the command right away.\e[0m"
    fi
    echo -e "\e[32mRun now: $SCRIPT_NAME\e[0m"
fi