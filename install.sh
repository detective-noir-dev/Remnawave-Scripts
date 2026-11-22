#!/bin/bash

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="rw-scripts"
REPO_URL="https://raw.githubusercontent.com/detective-noir-dev/Remnawave-Scripts/main"
CONFIG_DIR="$HOME/.config/remnawave"
LANG_FILE="$CONFIG_DIR/lang.conf"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/remnawave"

mkdir -p "$CONFIG_DIR" "$INSTALL_DIR" "$DATA_DIR"

# === ПРОВЕРКА И УСТАНОВКА SUDO ===
# Один список менеджеров пакетов: «имя|команда установки sudo». Порядок = приоритет.
SUDO_INSTALL_TABLE=(
    "apt-get|apt-get update -qq && apt-get install -y sudo"
    "dnf|dnf install -y sudo"
    "yum|yum install -y sudo"
    "pacman|pacman -Sy --noconfirm sudo"
    "zypper|zypper install -y sudo"
    "apk|apk add sudo"
)

# команда установки sudo для первого найденного менеджера (код 1, если менеджера нет)
sudo_install_cmd() {
    local entry
    for entry in "${SUDO_INSTALL_TABLE[@]}"; do
        if command -v "${entry%%|*}" >/dev/null 2>&1; then
            echo "${entry#*|}"
            return 0
        fi
    done
    return 1
}

check_and_install_sudo() {
    command -v sudo >/dev/null 2>&1 && return 0

    echo -e "\e[33m⚠️  'sudo' не найден в системе. Устанавливаю...\e[0m"
    local cmd
    cmd=$(sudo_install_cmd) || {
        echo -e "\e[31m❌ Не удалось определить пакетный менеджер.\e[0m"
        return 1
    }

    # без root поставить sudo нельзя: подсказываем команду и спрашиваем, продолжать ли
    if [ "$EUID" -ne 0 ]; then
        echo -e "\e[31m❌ Для установки sudo требуются права root.\e[0m"
        echo -e "\e[33m💡 Запустите скрипт от root или установите sudo вручную:\e[0m"
        echo "   su -c '$cmd'"
        read -rp "Продолжить установку без sudo? (y/n): " choice
        if [[ ! "$choice" =~ ^[YyДд]$ ]]; then
            echo -e "\e[31m❌ Установка отменена.\e[0m"
            exit 1
        fi
        return 1
    fi

    bash -c "$cmd"
    if command -v sudo >/dev/null 2>&1; then
        echo -e "\e[32m✅ sudo успешно установлен!\e[0m"
    else
        echo -e "\e[31m❌ Не удалось установить sudo.\e[0m"
        return 1
    fi
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

# настройки живут в config (ключ=значение); lang.conf остаётся для откатов на старые версии
CONFIG_FILE="$CONFIG_DIR/config"
if [ -f "$LANG_FILE" ] && ! grep -q '^lang=' "$CONFIG_FILE" 2>/dev/null; then
    printf 'lang=%s\n' "$(tr -d '\r\n' < "$LANG_FILE")" >> "$CONFIG_FILE"
fi

# === СКАЧИВАНИЕ ОСНОВНЫХ ФАЙЛОВ ===
download_file() {
    local name="$1" dest="$2"
    curl -fsSL --retry 2 -o "$dest.part" "$REPO_URL/$name" \
        && mv "$dest.part" "$dest" \
        || { rm -f "$dest.part"; echo -e "\e[31m❌ Failed to download $name\e[0m"; exit 1; }
}

# копия установленной версии для отката (становится "previous" только после успешной установки)
rm -rf "$DATA_DIR/previous.new"
if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ] && [ -s "$DATA_DIR/lib/pkg.sh" ]; then
    mkdir -p "$DATA_DIR/previous.new"
    cp "$INSTALL_DIR/$SCRIPT_NAME" "$DATA_DIR/previous.new/scripts.sh"
    cp -r "$DATA_DIR/lib" "$DATA_DIR/previous.new/lib"
    [ -d "$DATA_DIR/lang" ] && cp -r "$DATA_DIR/lang" "$DATA_DIR/previous.new/lang"
    [ -f "$DATA_DIR/version.txt" ] && cp "$DATA_DIR/version.txt" "$DATA_DIR/previous.new/version.txt"
fi

mkdir -p "$DATA_DIR/lang"
download_file lang/ru.sh "$DATA_DIR/lang/ru.sh"
download_file lang/en.sh "$DATA_DIR/lang/en.sh"
download_file uninstall.sh "$DATA_DIR/uninstall.sh"
chmod +x "$DATA_DIR/uninstall.sh"
download_file countries.csv "$DATA_DIR/countries.csv"

# Модули lib/*.sh скачиваем в staging, чтобы старые модули не оставались.
rm -rf "$DATA_DIR/lib.new"; mkdir -p "$DATA_DIR/lib.new"
LIB_NAMES=(cleaner cli common dante doctor firewall hy2 ids maintenance memory menus pkg scanner server system thirdparty warp)
for lib_name in "${LIB_NAMES[@]}"; do
    download_file "lib/$lib_name.sh" "$DATA_DIR/lib.new/$lib_name.sh"
done
rm -rf "${DATA_DIR:?}/lib"; mv "$DATA_DIR/lib.new" "$DATA_DIR/lib"

# version.txt
rm -f "$DATA_DIR/version.txt.new"
download_file version.txt "$DATA_DIR/version.txt"

# rw-scripts binary ставим последним
download_file scripts.sh "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# автодополнение bash для подкоманд (bash-completion подхватывает этот каталог сам); для zsh: rw-scripts completion zsh
COMP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"
if mkdir -p "$COMP_DIR" 2>/dev/null; then
    "$INSTALL_DIR/$SCRIPT_NAME" completion bash > "$COMP_DIR/rw-scripts.new" 2>/dev/null \
        && mv "$COMP_DIR/rw-scripts.new" "$COMP_DIR/rw-scripts" || rm -f "$COMP_DIR/rw-scripts.new"
fi

if [ -d "$DATA_DIR/previous.new" ]; then
    rm -rf "${DATA_DIR:?}/previous"; mv "$DATA_DIR/previous.new" "$DATA_DIR/previous"
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

# === ПРИМЕНЯЕМ BASHRC ===
if [ -f "$HOME/.bashrc" ]; then
    # shellcheck disable=SC1090
    source "$HOME/.bashrc" 2>/dev/null || true
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
        echo -e "\e[33m⚠️  PATH обновлён, но текущая сессия его ещё не видит.\e[0m"
        echo -e "\e[33m   Выполните в терминале:\e[0m"
        echo -e "\e[36m   source ~/.bashrc\e[0m"
        echo -e "\e[33m   — или откройте новый терминал.\e[0m"
        echo ""
    fi
    echo -e "\e[32mЗапуск: $SCRIPT_NAME\e[0m"
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
        echo -e "\e[33m⚠️  PATH was updated, but your current session doesn't see it yet.\e[0m"
        echo -e "\e[33m   Run in your terminal:\e[0m"
        echo -e "\e[36m   source ~/.bashrc\e[0m"
        echo -e "\e[33m   — or open a new terminal.\e[0m"
        echo ""
    fi
    echo -e "\e[32mRun now: $SCRIPT_NAME\e[0m"
fi
