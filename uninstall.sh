#!/bin/bash
# ==== UNINSTALL REMNAWAVE SCRIPTS ====

BIN_DIR="$HOME/.local/bin"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/remnawave"
CONFIG_DIR="$HOME/.config/remnawave"
BIN_FILE="$BIN_DIR/rw-scripts"

echo "====================================="
echo "  🗑️  Remnawave Scripts Uninstaller"
echo "====================================="

# ✅ Подтверждение
read -rp "Удалить rw-scripts и все его файлы? (y/n): " confirm
if [[ ! "$confirm" =~ ^[YyДд]$ ]]; then
    echo "❌ Отмена удаления."
    exit 0
fi

# ✅ Удаление бинаря
if [ -f "$BIN_FILE" ]; then
    rm -f "$BIN_FILE"
    echo "✔ Удалён бинарь: $BIN_FILE"
else
    echo "ℹ Бинарь $BIN_FILE не найден (пропущен)"
fi

# ✅ Удаление DATA
if [ -d "$DATA_DIR" ]; then
    rm -rf "$DATA_DIR"
    echo "✔ Удалены данные: $DATA_DIR"
else
    echo "ℹ Папка данных $DATA_DIR не найдена (пропущена)"
fi

# ✅ Удаление CONFIG
if [ -d "$CONFIG_DIR" ]; then
    rm -rf "$CONFIG_DIR"
    echo "✔ Удалены конфиги: $CONFIG_DIR"
else
    echo "ℹ Папка конфигов $CONFIG_DIR не найдена (пропущена)"
fi

echo "====================================="
echo "✅ Полное удаление завершено!"
echo "====================================="