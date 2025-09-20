#!/bin/bash

INSTALL_DIR="$HOME/.local/bin"
APP_DIR="$INSTALL_DIR/remnawave"
SCRIPT_NAME="rw-scripts"
REPO_URL="https://github.com/detective-noir-dev/Remnawave-Scripts.git"
CONFIG_DIR="$HOME/.config/remnawave"
LANG_FILE="$CONFIG_DIR/lang.conf"

# === Проверка наличия git ===
if ! command -v git >/dev/null 2>&1; then
    echo -e "\e[31m❌ Git не установлен. Установите git и повторите попытку.\e[0m"
    exit 1
fi

# === Проверка зависимостей ===
echo -e "\e[36m🔍 Проверка зависимостей...\e[0m"
NEEDED_CMDS=("curl" "xxd" "openssl")
MISSING_CMDS=()

for cmd in "${NEEDED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING_CMDS+=("$cmd")
    fi
done

if [ ${#MISSING_CMDS[@]} -gt 0 ]; then
    echo -e "\e[33m⚠️ Отсутствуют пакеты: ${MISSING_CMDS[*]}\e[0m"
    echo -e "\e[36m➡️ Устанавливаем...\e[0m"
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y curl vim-common openssl git
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y curl vim-common openssl git
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y curl vim-common openssl git
    elif command -v apk >/dev/null 2>&1; then
        sudo apk add --no-cache curl vim openssl git
    else
        echo -e "\e[31m❌ Не удалось определить пакетный менеджер. Установите вручную: curl vim-common openssl git\e[0m"
        exit 1
    fi
else
    echo -e "\e[32m✅ Все зависимости установлены.\e[0m"
fi

# === Получаем версию ===
VERSION=$(curl -fsSL "https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main/version.txt" 2>/dev/null | tr -d '\r\n')
[ -z "$VERSION" ] && VERSION="dev"

echo -e "\e[36m🚀 Установка Remnawave Scripts v$VERSION...\e[0m"

# === Выбор языка ===
echo -e "\nChoose installation language / Выберите язык установки:"
echo "1) English"
echo "2) Русский"
printf "Enter number (1/2): "
read -r lang_choice

mkdir -p "$CONFIG_DIR"
case "$lang_choice" in
    1) echo "en" > "$LANG_FILE"; LANG_NAME="English" ;;
    2) echo "ru" > "$LANG_FILE"; LANG_NAME="Русский" ;;
    *) echo "en" > "$LANG_FILE"; LANG_NAME="English (default)" ;;
esac
echo -e "\e[32mЯзык установлен: $LANG_NAME\e[0m\n"

# === Удаляем старую установку, если есть ===
rm -rf "$APP_DIR"

# === Скачиваем весь репозиторий через git clone ===
git clone --depth=1 "$REPO_URL" "$APP_DIR"

# === Создаём запускатель ===
ln -sf "$APP_DIR/scripts.sh" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$APP_DIR/scripts.sh"

# === Проверяем PATH ===
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    if ! grep -Fxq "export PATH=\$PATH:$INSTALL_DIR" "$HOME/.bashrc"; then
        echo "export PATH=\$PATH:$INSTALL_DIR" >> "$HOME/.bashrc"
        echo -e "\e[33m[!] Папка $INSTALL_DIR добавлена в PATH (перезапустите терминал)\e[0m"
    fi
fi

# === Финальное сообщение ===
LANG_SET=$(cat "$LANG_FILE")
echo
if [[ "$LANG_SET" == "ru" ]]; then
    echo -e "\e[32m✅ Установка завершена!\e[0m"
    echo "Установлена версия: $VERSION"
    echo "Запуск: $SCRIPT_NAME"
else
    echo -e "\e[32m✅ Installation complete!\e[0m"
    echo "Installed version: $VERSION"
    echo "Run with: $SCRIPT_NAME"
fi